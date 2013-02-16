module DuckMap

  ##################################################################################
  # Extracts the timestamp of each action for all of the controllers within the application
  # and stores it in config/locales/sitemap.yml
  class Sync
    
    ##################################################################################
    # Extract and store timestamps for all of the actions in the in app.
    # @param [Hash] options  An options Hash passed to the generator via the command line.
    # returns [Nil]
    def build(options = {})
      DuckMap.logger.info "\r\n\r\n====================================================================="
      DuckMap.logger.info "#{self.class.name} session begin at: #{Time.now}"
      DuckMap.logger.info "options: #{options}"

      verbose = options[:verbose].blank? ? false : true

      # always replace ALL of the existing content, so, the list is always current.
      # actions / views may have been deleted, renamed, etc.
      content = {sitemap: {}}
      grand_total = 0

      # controllers full physical path for the current app.
      base_dir = File.join(Rails.root, "app", "controllers").to_s

      # this is a little bit complex.
      # - traverse the entire directory structure for controllers.
      # - for each
      #   - inline gsub! to remove the base_dir.
      #   - inline gsub! to remove _controller.
      #   - then, prevent the application controller from making it into the list as
      #     there should not be any actions / views for the application controller.


      list = Dir["#{File.join(base_dir, "**", "*.rb")}"].each {|f| f.gsub!("#{base_dir}/", "").gsub!("_controller.rb", "")}.map.find_all {|x| x.eql?("application") ? false : true}

      DuckMap.console "Total number of controllers found within the app: #{list.length}"
      DuckMap.console "Views Controller"
      DuckMap.console "-------------------------------------------------------------"

      DuckMap.logger.show_console = verbose ? true : false

      list.each do |controller|

        file_spec = File.join("app", "views", controller)

        clazz = "#{controller}_controller".camelize.constantize

        DuckMap.console "===================================================================================="
        DuckMap.console "controller: #{controller.ljust(30)}  path: #{file_spec}"

        actions = {}
        methods = clazz.action_methods

        methods.each do |action|

          latest_timestamp = nil
          winner = nil

          DuckMap.console "    action: #{action}"

          Dir["#{File.join(file_spec, action)}.html.*"].each do |view|

            begin
              view_timestamp = File.stat(File.join(Rails.root, view)).mtime
              if view_timestamp.blank?
                DuckMap.console "          : cannot stat file: #{view}"
              else

                if latest_timestamp.blank? || view_timestamp > latest_timestamp
                  latest_timestamp = view_timestamp
                  winner = "timestamp from file"
                  DuckMap.console "          : Using    file timestamp? YES #{view}"
                  DuckMap.console "          :     file timestamp #{view_timestamp} greater than: #{latest_timestamp}"
                else
                  DuckMap.console "          : Using    file timestamp? NO #{view}"
                  DuckMap.console "          :     file timestamp #{view_timestamp} less than: #{latest_timestamp}"
                end

              end
            rescue Exception => e
              DuckMap.logger.debug "#{e}"
            end

            begin
              output = %x(git log --format='%ci' -- #{view} | head -n 1)
              if output.blank?
                DuckMap.console "          : cannot get date from GIT for file: #{view}"
              else

                view_timestamp = LastMod.to_date(output)
                if latest_timestamp.blank? || view_timestamp > latest_timestamp
                  latest_timestamp = view_timestamp
                  winner = "timestamp from GIT"
                  DuckMap.console "          : Using     GIT timestamp? YES #{view}"
                  DuckMap.console "          :     file timestamp #{view_timestamp} greater than: #{latest_timestamp}"
                else
                  DuckMap.console "          : Using     GIT timestamp? NO #{view}"
                  DuckMap.console "          :     file timestamp #{view_timestamp} less than: #{latest_timestamp}"
                end

              end
            rescue Exception => e
              DuckMap.logger.debug "#{e}"
            end

            begin
              view_timestamp = LastMod.to_date(I18n.t("#{controller.gsub("/", ".")}.#{action}", :locale => :sitemap))

              if view_timestamp.blank?
                DuckMap.console "          : cannot find item in locale sitemap.yml for file: #{view}"
              else

                view_timestamp = LastMod.to_date(output)
                if latest_timestamp.blank? || view_timestamp > latest_timestamp
                  latest_timestamp = view_timestamp
                  winner = "timestamp from locale sitemap.yml"
                  DuckMap.console "          : Using  locale timestamp? YES #{view}"
                  DuckMap.console "          :     file timestamp #{view_timestamp} greater than: #{latest_timestamp}"
                else
                  DuckMap.console "          : Using  locale timestamp? NO #{view}"
                  DuckMap.console "          :     file timestamp #{view_timestamp} less than: #{latest_timestamp}"
                end

              end

            rescue Exception => e
              DuckMap.logger.debug "#{e}"
            end

            DuckMap.console "          : winner #{winner}"

            begin
              actions.merge!(action => latest_timestamp.strftime("%m/%d/%Y %H:%M:%S"))
            rescue Exception => e
              DuckMap.logger.debug "#{e}"
            end

          end
        end

        # add all of the actions found for the current controller to the :sitemap section of the yaml file.
        if actions.length > 0
          grand_total += actions.length
          namespaces = controller.split("/")
          content[:sitemap] = merge_controller(content[:sitemap], namespaces, 0, actions)

          DuckMap.logger.show_console = true
          DuckMap.console "#{actions.length.to_s.rjust(5)} #{controller}"
          DuckMap.logger.show_console = verbose ? true : false

        end

      end

      DuckMap.logger.show_console = true
      DuckMap.console "\r\nTotal number of views synchronized: #{grand_total}\r\n"
      DuckMap.logger.info "#{self.class.name} session end at: #{Time.now}"
      DuckMap.logger.info "---------------------------------------------------------------------"

      # done.
      write_config(content)
      DuckMap.console "done."

    end
    
    ##################################################################################
    # Recursive method
    def merge_controller(content, namespaces, index, values = {})

      if (index == (namespaces.length - 1))
        content[namespaces[index]] = {} unless content.has_key?(namespaces[index])
        content[namespaces[index]].merge!(values)
      else
        content[namespaces[index]] = {} unless content.has_key?(namespaces[index])
        content[namespaces[index]] = merge_controller(content[namespaces[index]], namespaces, index + 1, values)
      end
      return content
    end

    ##################################################################################
    def write_config(values = {})
      File.open(File.join(Rails.root, "config", "locales", "sitemap.yml"), "w") do |file|
        file.puts "# Although this file is automatically generated, it is ok to edit."
        YAML.dump(values, file)
      end
    end

  end

end
