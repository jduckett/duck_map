module DuckMap

  class SitemapStaticRequest < ActionDispatch::Request
  end

  class SitemapStaticResponse < ActionDispatch::Response
  end

  class ActionViewTestObject < ActionView::Base
    include DuckMap::ActionViewHelpers
    include DuckMap::SitemapControllerHelpers
    include DuckMap::Model
    include DuckMap::SitemapHelpers

  end

  ##################################################################################
  class Static

    ##################################################################################
    def build(options = {})
      key = options[:key].blank? ? :all : options[:key].to_s.downcase.to_sym

      begin

        attributes = DuckMap::Config.attributes

        compressed = attributes[:compression].blank? ? :compressed : attributes[:compression]

        # command line override config
        compressed = options[:compression].blank? ? compressed : options[:compression]

        compressed = compressed.blank? ? :compressed : compressed.to_s.downcase.to_sym
        compressed = compressed.eql?(:compressed) ? true : false

        static_host = attributes[:static_host].blank? ? attributes[:canonical_host] : attributes[:static_host]

        # command line override config
        static_host = options[:static_host].blank? ? static_host : options[:static_host]

        static_port = attributes[:static_port].blank? ? attributes[:canonical_port] : attributes[:static_port]

        # command line override config
        static_port = options[:static_port].blank? ? static_port : options[:static_port]

        static_target = attributes[:static_target].blank? ? File.join(Rails.root, "public") : attributes[:static_target]

        # command line override config
        static_target = options[:static_target].blank? ? static_target : options[:static_target]

        if !static_host.blank?

          request_options = {
                              "rack.input" => StringIO.new,
                              "rack.errors" => StringIO.new,
                              "rack.multithread" => true,
                              "rack.multiprocess" => true,
                              "rack.run_once" => false,
                              "CONTENT_TYPE" => "application/xml",
                              "HTTP_HOST" => static_host,
                              "SERVER_PORT" => static_port}

          DuckMap.console "Searching for route: #{key}"

          routes = []
          if key.eql?(:all)

            routes = Rails.application.routes.sitemap_routes_only

          else

            route = Rails.application.routes.find_route_via_name("#{key}_sitemap")
            if route.blank?
              DuckMap.console "Unable to find route: #{key}"
            else
              routes.push(route)
            end

          end

          routes.each do |route|

            DuckMap.console "Processing route: #{route.name}"

            clazz = ClassHelpers.get_controller_class(route.controller_name)

            if clazz.blank?
              DuckMap.logger.debug "sorry, could not determine controller class...: route name: #{route.name} controller: #{route.controller_name}  action: #{route.action_name}"
            else

              controller = clazz.new

              controller.request = SitemapStaticRequest.new(request_options)
              controller.response = SitemapStaticResponse.new

              # man, I am getting lazy...
              request_path = route.path.spec.to_s.gsub(":format", "xml")

              controller.sitemap_build(request_path)

              view = ActionViewTestObject.new(File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "app", "views")))

              view.controller = controller

              view.assign(sitemap_model: controller.sitemap_model)

              parts = request_path.split("/")
              parts.insert(0, static_target)

              file_spec = File.join(parts)

              File.open(file_spec, "w") do |file|

                file.write view.render(:template => "sitemap/default_template.xml.erb")

              end

              if compressed

                Zlib::GzipWriter.open("#{file_spec}.gz") do |gz|
                  gz.mtime = File.mtime(file_spec)
                  gz.orig_name = file_spec
                  gz.write IO.binread(file_spec)
                end

                FileUtils.rm_rf file_spec

              end

            end

          end

        else
          DuckMap.console "Sorry, cannot build sitemap.  You need to set static_host in config/routes.rb or on the command-line..."
        end

      rescue Exception => e
        puts "#{e.message}"
        puts e.backtrace
      end

    end

  end
end
