require 'active_support/concern'

module DuckMap
  module Handlers

    autoload :Index, "duck_map/handlers/index"
    autoload :Show, "duck_map/handlers/show"

    ##################################################################################
    # Base module containing common code for all sitemap handler modules.
    module Base
      extend ActiveSupport::Concern

      ##################################################################################
      # Finds the first instance of a model object on the current controller object.
      # sitemap_first_model will respect the current setting of :first_model.  If :first_model
      # is true, then, it will continue the search and return the first instance of a model object
      # on the current controller object.  Otherwise, it will return nil.
      #
      # @param [Hash] handler   The handler Hash of a sitemap configuration.
      # @return [ActiveRecord::Base]
      def sitemap_first_model(handler = {})
        value = nil

        begin

          # determine if we are suppose to look for the first model on the current controller.
          if handler.kind_of?(Hash) && handler[:first_model]

            first_model_object = self.find_first_model_object

            unless first_model_object.blank?
              value = first_model_object
            end

          end

        rescue Exception => e
          # expect this exception to occur EVERYTIME...
        end

        return value
      end

      ##################################################################################
      # Returns a copy of the current values held by {DuckMap::Config.attributes}
      # @return [Hash]
      def sitemap_defaults(options = {})
        return DuckMap::Config.copy_attributes
      end

      ##################################################################################
      # Applies the current url limit to a result set.  This is really a helper method used
      # by all of the handler methods that return a Array of Hashes numbering greater than one.
      # Handler methods that would normally return one row need not use this helper method.
      # Use it if you implement a custom handler method.
      # @param [Array] rows         An Array of Hashes representing the contents of a sitemap.
      # @param [Hash] options       The :handler section of a sitemap configuration.
      # @option options [Symbol]    :url_limit    An integer limiting the number of rows to return.
      # @return [Array]
      def sitemap_url_limit(rows, options = {})

        unless options[:url_limit].blank?
          if rows.length > options[:url_limit]
            rows.slice!(options[:url_limit], rows.length)
          end
        end

        return rows
      end

      ##################################################################################
      # @return [Hash]
      def sitemap_url_options(options = {})
        values = {}

        unless options[:url_format].blank?
          values[:format] = options[:url_format]
        end

        return values.merge(sitemap_host_options(options))
      end

      ##################################################################################
      # @return [Hash]
      def sitemap_host_options(options = {})
        values = {}

        unless options[:canonical_host].blank?
          values[:host] = options[:canonical_host]
        end
        unless options[:canonical_port].blank?
          values[:port] = options[:canonical_port]
        end

        return values
      end

    end

  end
end
