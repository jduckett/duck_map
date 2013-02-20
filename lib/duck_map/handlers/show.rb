require 'active_support/concern'

module DuckMap
  module Handlers

    ##################################################################################
    module Show
      extend ActiveSupport::Concern

      ##################################################################################
      def sitemap_show(options = {})
        rows = []

        # always start off with default values from config, then, simply overwrite them as we progress.
        values = sitemap_defaults(options)

        # show action never needs to call the existing show action.

        lastmod = self.sitemap_static_lastmod(options[:controller_name], options[:action_name])
        unless lastmod.blank?
          values[:lastmod] = lastmod
        end

        # first, capture the values from the controller.
        attributes = self.sitemap_stripped_attributes(options[:action_name])
        values = values.merge(self.sitemap_capture_attributes(attributes))

        if options[:source] == :meta_data

          # capture values from the first available model unless disabled.
          model_object = sitemap_first_model(options[:handler])

          unless model_object.blank?
            model_attributes = attributes
            if model_object.is_sitemap_attributes_defined?
              model_attributes = model_object.sitemap_stripped_attributes(options[:action_name])
            end

            values = values.merge(model_object.sitemap_capture_attributes(model_attributes))

          end

          if values[:canonical].blank?
            route = Rails.application.routes.find_route_via_path(request.path)
            url_options = sitemap_url_options(values)
            values[:canonical] = self.send("#{route.name}_url", url_options)
            values[:loc] = values[:canonical]
          else
            values[:loc] = values[:canonical]
          end

          rows.push(values)

          self.sitemap_meta_data = values

        else

          data_rows = []

          if !options[:handler][:block].blank?

            data_rows = options[:handler][:block].call(options)

          elsif !options[:handler][:model].blank?

            data_rows = options[:handler][:model].send(:all)

          elsif !options[:model].blank?

            # this model is not set by developer
            # it is set in code in sitemap_build using get_model_class
            data_rows = options[:model].send(:all)

          end

          # data_rows may have changed from an Array to a model object.
          # Make data_rows an Array if it has been switched to an model object.
          if data_rows.kind_of?(ActiveRecord::Base)
            data_rows = [data_rows]
          end

          # only process the first row since we are processing the index action of the controller
          if data_rows.kind_of?(Array) && data_rows.length > 0

            data_rows.each do |data_row|

              # this is how we are overriding attributes defined on the controller with attributes
              # defined on the model.  The model attributes win!
              # same thing for segments below.
              model_attributes = attributes
              segment_mappings = self.sitemap_attributes(options[:action_name])[:segments]

              if data_row.is_sitemap_attributes_defined?
                model_attributes = data_row.sitemap_stripped_attributes(options[:action_name])
                segment_mappings = data_row.sitemap_attributes(options[:action_name])[:segments]
              end

              row_values = values.merge(data_row.sitemap_capture_attributes(model_attributes))

              url_options = sitemap_url_options(row_values)

              if row_values[:canonical].blank?

                segments = data_row.sitemap_capture_segments(segment_mappings, options[:route].segments)
                row_values[:canonical] = self.send("#{options[:route].name}_url", url_options.merge(segments))
                row_values[:loc] = row_values[:canonical]

              else
                row_values[:loc] = row_values[:canonical]
              end

              rows.push(row_values)

            end

          end

        end

        return sitemap_url_limit(rows, options[:handler])
      end

    end

  end
end
