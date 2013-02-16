require 'active_support/concern'

module DuckMap
  module Handlers

    ##################################################################################
# get default values and assign to local variable containing all values from a single url node
# and meta tag values for the index action.  the local variable is referred to as "values".
# - user can override method and manipulate the default values...
# index action is called.
# - uses existing values generated via the index method
# - gives the developer a chance to set instance values to handle special cases
# lastmod is obtained from locale and merged with "values".
# call sitemap_capture_attributes on the controller to capture values of the current state and merge them with "values".
# 
    module Index
      extend ActiveSupport::Concern

      ##################################################################################
      def sitemap_new(options = {})
        return []
      end

      ##################################################################################
      def sitemap_edit(options = {})
        return []
      end

      ##################################################################################
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

          data_rows = options[:handler][:model].send(:all)

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
        if data_rows.kind_of?(ActiveRecord::Base)
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

        rows.push(values)

        self.sitemap_meta_data = values

        return rows
      end

    end

  end
end
