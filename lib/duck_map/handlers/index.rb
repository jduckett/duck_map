require 'active_support/concern'

module DuckMap
  module Handlers

    ##################################################################################
    module Index
      extend ActiveSupport::Concern

      ##################################################################################
      # Default handler method for index actions.
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
      # - if request source is :sitemap, then, the index method of the controller is called.
      #   This will allow you to set instance variables, etc. within the index method of a controller.
      # - static last-modified date is obtained from config/locales/sitemap.yml
      # - sitemap_capture_attributes is called directly on the controller.  Any values are merged with the return Hash.
      # - process some type of model in the following order of precedence depending on configuration.
      #   - process block
      #     if the controller was configured with a block, then, execute the block and use the return value
      #     as the data source for values.
      #   - process model configured via the handler
      #     if a model class was assigned to the handler, then, execute "all" method on the model and use the return value
      #     as the data source for values.
      #   - first model object automagically found on the controller
      #     unless "first_model" has been set to false, find the first instance of a model object on the controller
      #     and use it as the data source for values.
      # - once a data source object has been established, call sitemap_capture_attributes to obtain values and merge
      #   them with the return Hash.
      # - unless a canonical url has been obtained during any of the preceding steps, build the canonical url
      #   based on the route and data source object found during preceding steps. 
      # - add the return Hash to the return Array and set the meta tag instance variable.
      # - done.
      # @return [Array]
      def sitemap_index(options = {})
        rows = []

        # always start off with default values from config, then, simply overwrite them as we progress.
        values = sitemap_defaults(options)

        # if the source is meta_data, that means the call to sitemap_index is the result of a user
        # requesting an index page.  Therefore, there would be no reason to call the index action, because,
        # it has already been called and any instance variable have been set.
        # Otherwise, if this is the result of a sitemap request, then, call the index action to simulate
        # as if it were a user making the request.
        if options[:source] == :sitemap

          begin

            index

          rescue Exception => e
            # expect this exception to occur EVERYTIME...
          end

        end

        lastmod = self.sitemap_static_lastmod(options[:controller_name], options[:action_name])
        unless lastmod.blank?
          values[:lastmod] = lastmod
        end

        # first, capture the values from the controller.
        attributes = self.sitemap_stripped_attributes(options[:action_name])
        values = values.merge(self.sitemap_capture_attributes(attributes))

        data_rows = []

        if !options[:handler][:block].blank?

          data_rows = options[:handler][:block].call(options)

        elsif !options[:handler][:model].blank?

          data_rows = options[:handler][:model].send(:all).to_a

        else

          # capture values from the first available model unless disabled.
          model_object = sitemap_first_model(options[:handler])
          unless model_object.blank?
            model_attributes = attributes
            if model_object.is_sitemap_attributes_defined?
              model_attributes = model_object.sitemap_stripped_attributes(options[:action_name])
            end

            values = values.merge(model_object.sitemap_capture_attributes(model_attributes))
          end

        end

        # data_rows may have changed from an Array to a model object.
        # Make data_rows an Array if it has been switched to an model object.
        if data_rows.kind_of?(ActiveRecord::Base) || data_rows.kind_of?(Mongoid::Document)
          data_rows = [data_rows]
        end

        # only process the first row since we are processing the index action of the controller
        if data_rows.kind_of?(Array) && data_rows.length > 0

          data_row = data_rows.first

          model_attributes = attributes
          if data_row.is_sitemap_attributes_defined?
            model_attributes = data_row.sitemap_stripped_attributes(options[:action_name])
          end

          values = values.merge(data_row.sitemap_capture_attributes(model_attributes))

        end

        if values[:canonical].blank?

          route = options[:source] == :meta_data ? Rails.application.routes.find_route_via_path(request.path) : options[:route]

          url_options = sitemap_url_options(values)

          # forgive me father for I have hacked...
          # i'm really being lazy here, but, if the current route is
          # the root, then, reassign the url to eliminate ?format=html, etc.
          # from the url.
          # index actions do not require segment keys, therefore, no need to process them.
          if !route.name.blank? && route.name.eql?("root")
            url_options.delete(:format)
            values[:canonical] = root_url(url_options)
          else
            values[:canonical] = self.send("#{route.name}_url", url_options)
          end

          values[:loc] = values[:canonical]
        else
          values[:loc] = values[:canonical]
        end

        # push the merged hash and set the instance variable for the meta tag
        rows.push(values)

        self.sitemap_meta_data = values

        return rows
      end

    end

  end
end
