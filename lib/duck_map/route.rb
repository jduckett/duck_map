require 'active_support/concern'

module DuckMap

  ##################################################################################
  # Conveience methods that wrap standard ActionDispatch::Routing::Route methods and data.
  # The purpose is to harness the existing code to allow extra config arguments to be included
  # on routes within config/routes.rb.  ActionDispatch::Routing::Route has a couple of instance variables
  # (defaults and requirements).
  #   - defaults is a Hash that contains the arguments passed to methods within config/routes.rb such as
  #     resources, match, etc.  The arguments passed to most routes config methods will actually make a call
  #     to match to add a route and will include any extra arguments you pass in the defaults Hash.
  #     The methods of this module extract those values.
  #   - requirements is a Hash that contains the controller and action name of the current route.
  module Route
    extend ActiveSupport::Concern
    include DuckMap::ArrayHelper

    ##################################################################################
    #module InstanceMethods

      # Identifies the current routes as being a sitemap route.
      attr_accessor :is_sitemap

      # The route name of the sitemap which the current route is assigned.
      attr_accessor :sitemap_route_name

      # The route name of the sitemap without the namespace.
      attr_accessor :sitemap_raw_route_name

      # Identifies that the current sitemap route was defined with a block.
      attr_accessor :sitemap_with_block

      # Total amount of URL nodes allowed in the sitemap.
      attr_accessor :url_limit

      ##################################################################################
      # Identifies the current routes as being a sitemap route.
      # @return [Boolean]  True if the route is a sitemap route, otherwise, false.
      def is_sitemap?
        @is_sitemap = @is_sitemap.nil? ? false : @is_sitemap
      end

      ##################################################################################
      # @return [String] Namespace prefix used when creating the route.
      def namespace_prefix
        value = nil

        unless self.sitemap_raw_route_name.blank?
          value = self.sitemap_route_name.gsub(self.sitemap_raw_route_name, "")
        end

        return value
      end

      ##################################################################################
      def namespace_prefix_underscores
        value = 0

        buffer = self.namespace_prefix
        unless buffer.blank?
          value = buffer.split("_").length
        end

        return value
      end

      ##################################################################################
      # Identifies that the current sitemap route was defined with a block.
      # @return [Boolean]  True if the route was defined with a block, otherwise, false.
      def sitemap_with_block?
        @sitemap_with_block = @sitemap_with_block.nil? ? false : @sitemap_with_block
      end

      ##################################################################################
      # Conveience method to return the name assigned to the route.  There is no need for nil
      # checking the return value of this method.  It will simply return an empty String.
      # @return [String] Name assigned to the route.
      def route_name
        return "#{self.name}"
      end

      ##################################################################################
      # Returns the controller_name assigned to the route.
      # @return [String] Controller_name name assigned to the route.
      def controller_name
        return self.requirements[:controller].blank? ? "" : self.requirements[:controller].to_s
      end

      ##################################################################################
      # Returns the action assigned to the route.
      # @return [String] Action name assigned to the route.
      def action_name
        return self.requirements[:action].blank? ? "" : self.requirements[:action].to_s
      end

      ##################################################################################
      # The class name (as a String) of a model to be used as the source of rows for a route
      # when generating sitemap content.
      # @return [String]
      def model
        return self.defaults[:model]
      end

      ##################################################################################
      # Setting changefreq directly on the route will override values set within a controller and model.
      # This value will be used when generating a sitemap for the specific route.
      #
      #    MyApp::Application.routes.draw do
      #
      #      resources :trucks, :changefreq => "daily"
      #
      #    end
      #
      # produces url's like the following:
      #
      #    <url>
      #      <loc>http://localhost:3000/trucks/1.html</loc>
      #      <lastmod>2011-10-13T06:16:24+00:00</lastmod>
      #      <changefreq>daily</changefreq>
      #      <priority>0.5</priority>
      #    </url>
      #
      # @return [String] Current value of changefreq.
      def changefreq
        return self.defaults[:changefreq]
      end

      ##################################################################################
      # Setting priority directly on the route will override values set within a controller and model.
      # This value will be used when generating a sitemap for the specific route.
      #
      #    MyApp::Application.routes.draw do
      #
      #      resources :trucks, :priority => "0.4"
      #
      #    end
      #
      # produces url's like the following:
      #
      #    <url>
      #      <loc>http://localhost:3000/trucks/1.html</loc>
      #      <lastmod>2011-10-13T06:16:24+00:00</lastmod>
      #      <changefreq>monthly</changefreq>
      #      <priority>0.4</priority>
      #    </url>
      #
      # @return [String] Current value of priority.
      def priority
        return self.defaults[:priority]
      end

      ##################################################################################
      # Specifies the extension that should be used when generating a url for the route within a sitemap.
      #
      #    MyApp::Application.routes.draw do
      #
      #      resources :trucks, :url_format => "xml"
      #
      #    end
      #
      # produces url's like the following:
      #
      #    <loc>http://localhost:3000/trucks/1.xml</loc>
      #    <loc>http://localhost:3000/trucks/2.xml</loc>
      #
      # @return [String]
      def url_format
        # a quick hack to default the extension for the root url to :none
        return self.defaults[:url_format].blank? && self.route_name.eql?("root") ? :none : self.defaults[:url_format]
      end

      ##################################################################################
      def exclude_actions
        return self.duckmap_defaults(:exclude_actions)
      end

      ##################################################################################
      def exclude_controllers
        return self.duckmap_defaults(:exclude_controllers)
      end

      ##################################################################################
      def exclude_names
        return self.duckmap_defaults(:exclude_names)
      end

      ##################################################################################
      def exclude_verbs
        return self.duckmap_defaults(:exclude_verbs)
      end

      ##################################################################################
      def include_actions
        return self.duckmap_defaults(:include_actions)
      end

      ##################################################################################
      def include_controllers
        return self.duckmap_defaults(:include_controllers)
      end

      ##################################################################################
      def include_names
        return self.convert_to(self.duckmap_defaults(:include_names), :string)
      end

      ##################################################################################
      def include_verbs
        return self.duckmap_defaults(:include_verbs)
      end

      ##################################################################################
      def verb_symbol
        value = nil
          unless self.verb.blank?
            buffer = self.verb.to_s.downcase
            if buffer.include?("delete")
              value = :delete

            elsif buffer.include?("get")
              value = :get

            elsif buffer.include?("post")
              value = :post

            elsif buffer.include?("put")
              value = :put

            end

          end
        return value
      end

      ##################################################################################
      # Indicates if the current route requirements segments keys to generate a url.
      # @return [Boolean] True if keys are required to generate a url, otherwise, false.
      def keys_required?
        keys = self.segment_keys.dup
        keys.delete(:format)
        return keys.length > 0 ? true : false
      end

      ##################################################################################
      # Looks for a key within ActionDispatch::Routing::Route.defaults.
      # If found:
      #   - determine the type of value:
      #     - If Array, return the array.
      #     - If String, create an array, add the String to it, and return the array.
      #     - If Symbol, create an array, add the Symbol to it, and return the array.
      # If nothing found, return an empty array.
      # returns [Array]
      def duckmap_defaults(key)
        values = []

        if self.defaults && self.defaults[key]
          if self.defaults[key].kind_of?(Array)
            values = self.defaults[key]

          elsif self.defaults[key].kind_of?(String)
            values.push(self.defaults[key])

          elsif self.defaults[key].kind_of?(Symbol)
            values.push(self.defaults[key])

          end
        end

        return values
      end
    #end

  end
end
