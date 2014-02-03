require 'active_support/concern'

module DuckMap
  module Handlers

    ##################################################################################
    module Show
      extend ActiveSupport::Concern

      ##################################################################################
      # Default handler method for show actions.
      #
      # The source of a request for data can be from two sources.
      # - sitemap requesting url nodes for a given route.
      # - meta tag requesting data for HEAD section meta tags.
      #
      # This method will return an Array of Hashes that represent url nodes of a sitemap.  Also,
      # sitemap_meta_data is populated with a single Hash for meta tags.  So, this is considered
      # a shared method.
      #
      # The basic procedure is as follows:
      #
      # - default values are obtained from {DuckMap::Config} and stored in a return Hash.
      # - the controller "show" action method is never called as it is not needed.
      #   - if the request is a meta tag, then, the show method has already been called.
      #   - if the request is a sitemap, then, we would looking for a list of rows instead of just one
      #     row, because, a show route would always be pointing to a single item and the sitemap would want to show
      #     all of those items or at least a defined list of them.
      # - static last-modified date is obtained from config/locales/sitemap.yml
      # - sitemap_capture_attributes is called directly on the controller.  Any values are merged with the return Hash.
      # - now, the processing splits based on the type of request.
      # - if meta tag
      #   - first model object automagically found on the controller
      #     unless "first_model" has been set to false, find the first instance of a model object on the controller
      #     and use it as the data source for values.
      #   - unless a canonical url has been obtained during any of the preceding steps, build the canonical url
      #     based on the route and data source object found during preceding steps.  the segment keys are NOT processed
      #     as the values should be automagically part of the url building since this is being called as part of an
      #     HTTP request.  The segment key should simply already be there.
      #   - add the return Hash to the return Array and set the meta tag instance variable.
      # - otherwise, assume sitemap
      #   - process some type of model in the following order of precedence depending on configuration.
      #     - process block
      #       if the controller was configured with a block, then, execute the block and use the return value
      #       as the data source for values.
      #     - process model configured via the handler
      #       if a model class was assigned to the handler, then, execute "all" method on the model and use the return value
      #       as the data source for values.
      #     - model object automagically found by the sitemap_build method.
      #       the "all" method is called on the model object.
      #     - first model object is never processed for the show method when the request is via a sitemap.
      #       the reason is the show method is never called, therefore, an instance of a model would not exist on the controller.
      #   - the goal is ALWAYS to work with a list of model objects.  once a list has been established,
      #     process all of the model objects in the list.
      #     - for each object
      #       - build a row Hash based copied from all of the values captured thus far.
      #       - call sitemap_capture_attributes on the model to obtain values and merge them with the row Hash.
      #       - unless a canonical url has been obtained during any of the preceding steps, build the canonical url
      #         based on the route and data source object found during preceding steps.  segment keys are build via a call
      #         to sitemap_capture_segments on the model.
      #       - add the row Hash to the return Array
      #       - do nothing to the meta tag instance variable.
      # - done.
      # @return [Array]
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

            data_rows = options[:handler][:model].send(:all).to_a

          elsif !options[:model].blank?

            # this model is not set by developer
            # it is set in code in sitemap_build using get_model_class
            data_rows = options[:model].send(:all).to_a
          end

          # data_rows may have changed from an Array to a model object.
          # Make data_rows an Array if it has been switched to an model object.
          if data_rows.kind_of?(ActiveRecord::Base) || data_rows.kind_of?(Mongoid::Document)
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
