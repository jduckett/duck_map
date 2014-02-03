require 'active_support/concern'

module DuckMap

  ##################################################################################
# NOT empty anymore...
  # This module is empty on purpose.  Sitemap::Mapper will create a sitemap method on this
  # module when a sitemap is actually created via config/routes.rb.  This module is included in the SitemapBaseController
  # and therefore will have all of the methods defined via config/routes.rb.
  # Originally, methods were defined directly on SitemapBaseController, however, it was creating
  # some wierd problems during development.  Meaning, if you tried to edit and refresh (Rails standard)
  # the Rails stack would blow up.  Adding the methods to a module and including the module seemed to fix
  # the problem.
  module SitemapControllerHelpers

    ##################################################################################
    def sitemap_build(request_path = nil)

      self.sitemap_model = []

      begin

        request_path = request_path.blank? ? request.path : request_path

        sitemap_route = Rails.application.routes.find_sitemap_route(request_path)
        unless sitemap_route.blank?
          Rails.application.routes.sitemap_routes(sitemap_route).each do |route|

          begin

            DuckMap.logger.info "processing route:  name: #{route.name}  controller: #{route.controller_name}  action: #{route.action_name}"

            clazz = ClassHelpers.get_controller_class(route.controller_name)

            if clazz.blank?
              DuckMap.logger.debug "sorry, could not determine controller class...: route name: #{route.name} controller: #{route.controller_name}  action: #{route.action_name}"
            else

              controller_object = clazz.new
              controller_object.request = request
              controller_object.response = ActionDispatch::Response.new

              begin

                options = { action_name: route.action_name,
                            controller_name: route.controller_name,
                            model: ClassHelpers.get_model_class(route.controller_name),
                            route: route,
                            source: :sitemap}

                rows = controller_object.sitemap_setup(options)
                if rows.kind_of?(Array) && rows.length > 0
                  self.sitemap_model.concat(rows)
                end

              rescue Exception => e
                DuckMap.logger.exception(e)
              end

            end

          rescue Exception => e
            DuckMap.logger.exception(e)
          end

          end
        end

        self.sitemap_model.each do |item|
          unless item[:lastmod].kind_of?(String)
            item[:lastmod] = item[:lastmod].to_s(:sitemap)
          end
        end

      rescue Exception => e
        DuckMap.logger.exception(e)
      end

      return nil
    end

  end

  ##################################################################################
  module ControllerHelpers
    extend ActiveSupport::Concern

    ##################################################################################
    # Determines all of the attributes defined for a controller, then, calls the handler method on the controller
    # to generate and return an Array of Hashes representing all of the url nodes to be included in the sitemap
    # for the current route being processed.
    # @return [Array] An Array of Hashes.
    def sitemap_setup(options = {})
      rows = []

      DuckMap.logger.debug "sitemap_setup: action_name => #{options[:action_name]} source => #{options[:source]} model => #{options[:model]}"

      attributes = self.sitemap_attributes(options[:action_name])

      DuckMap.logger.debug "sitemap_setup: attributes => #{attributes}"

      if attributes.kind_of?(Hash) && attributes[:handler].kind_of?(Hash) && !attributes[:handler][:action_name].blank?
        config = {handler: attributes[:handler]}.merge(options)
        rows = self.send(attributes[:handler][:action_name], config)
      end

      return rows
    end

    ##################################################################################
    # Returns the current value of the instance variable {#sitemap_meta_data}.
    def sitemap_meta_data
      unless defined?(@sitemap_meta_data)
        @sitemap_meta_data = {}
        self.sitemap_setup({action_name: action_name,
                            controller_name: controller_name,
                            route: nil,
                            source: :meta_data})
      end
      return @sitemap_meta_data
    end

    def sitemap_meta_data=(value)
      @sitemap_meta_data = value
    end

    ##################################################################################
    def find_first_model_object
      model_object = self.find_model_object

      if model_object.kind_of?(Array) &&
          (model_object.first.kind_of?(ActiveRecord::Base) || model_object.first.kind_of?(Mongoid::Document))
        model_object = model_object.first
      end

      return model_object
    end

    ##################################################################################
    def find_model_object
      model_object = nil
      candidate = nil
      skip_vars = ["@_config",
                    "@view_renderer",
                    "@_routes",
                    "@_assigns",
                    "@_request",
                    "@view_flow",
                    "@output_buffer",
                    "@virtual_path"]

      list = self.instance_variables.map.find_all {|x| !skip_vars.include?(x.to_s)}

      list.each do |obj_sym|
        obj = self.instance_variable_get(obj_sym)
        if obj
          if obj.kind_of?(ActiveRecord::Base) || obj.kind_of?(Mongoid::Document)
            model_object = obj
            break
          elsif obj.kind_of?(Array) &&
                (obj.first.kind_of?(ActiveRecord::Base) || obj.first.kind_of?(Mongoid::Document)) &&
                candidate.blank?
            candidate = obj
          end
        end
      end

      if model_object.blank? && !candidate.blank?
        model_object = candidate
      end

      return model_object
    end

    ##################################################################################
    # Returns the date / time value from config/locale/sitemap.yml associated with the current controller / action.
    # The static date/times are actual timestamps extracted from the date of the view on disk and from a .git repository if used.
    # Be sure to run the generator or rake task: duck_map:sync to populate the locale file at: config/locale/sitemap.yml
    # @return [DateTime] The timestamp associated with the controller / action.
    def sitemap_static_lastmod(my_controller_name = nil, my_action_name = nil)
      value = nil

      unless my_controller_name.blank? || my_action_name.blank?

        unless my_controller_name.blank?
          my_controller_name = my_controller_name.underscore
          my_controller_name = my_controller_name.gsub("/", ".")
        end

        begin

          value = I18n.t("#{my_controller_name.downcase}.#{my_action_name.downcase}", default: "", locale: :sitemap)

        rescue Exception => e
          DuckMap.logger.exception(e)
        end

        value = value.blank? ? nil : LastMod.to_date(value)

      end

      return value
    end

  end

end
