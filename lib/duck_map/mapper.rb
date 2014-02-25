require 'active_support/concern'

module DuckMap
    
  ##################################################################################
  # Add functionality to ActionDispatch::Routing::Mapper  The purpose of this module
  # is to provide methods that can be used within config/routes.rb to define sitemaps
  # and configure sitemap options.
  module Mapper
    extend ActiveSupport::Concern

    ##################################################################################
    # Defines a sitemap for a Rails app.
    #
    #
    # You can find a few examples and apps at:
    # - (http://www.jeffduckett.com/blog/11/defining-rails-3-x-sitemaps-using-duckmap.html)
    # - (http://www.jeffduckett.com/blog/12/multiple-sitemap-definitions.html)
    #
    # @return [Nil]
    def sitemap(name = :sitemap, options = {}, &block)
      options = name.kind_of?(Hash) ? name : options
      name = name.kind_of?(String) || name.kind_of?(Symbol) ? name : :sitemap
      config = {controller: :sitemap, url_limit: nil}.merge(options)

      sitemap_raw_route_name = "#{name}_sitemap"
      sitemap_route_name = name_for_action(sitemap_raw_route_name, nil)

      begin

        unless @set.routes.find {|route| route.name.eql?(sitemap_route_name)}

          # create a route for the sitemap using the name that was passed to the sitemap method inside config/routes.
          match %(/#{name}.:format), controller: config[:controller], action: name, via: [:get], as: sitemap_raw_route_name

          # if not found here, then, there must be a real problem.
          # later, i will implement an exception, etc.
          sitemap_route = @set.routes.find {|route| route.name.eql?(sitemap_route_name)}

          # identify the route as a "sitemap" route and build it's full name.
          sitemap_route.is_sitemap = true
          sitemap_route.url_limit = config[:url_limit]
          sitemap_route.sitemap_route_name = sitemap_route_name
          sitemap_route.sitemap_raw_route_name = sitemap_raw_route_name

          # this is how I am faking to always point to the SitemapController
          # regardless of namespace
          sitemap_route.defaults[:controller] = "sitemap"

        end

      rescue ArgumentError => e
        unless e.message.include?("Invalid route name")
          raise e
        end
      end

      # now, find the route again, because, we need to set the following boolean and there might be several
      # calls to sitemap without a block.  if we were to set this boolean in the code above when checking
      # if the route already exists, then, the boolean may never be set.
      sitemap_route = @set.routes.find {|route| route.is_sitemap? && route.name.eql?(sitemap_route_name) }

      # once a sitemap route has been flagged as being defined with a block, then, you should never set it back to false.
      # one of the features is to be able to encapsulate a set of routes within a sitemap as many times as you need.
      # meaning, you might want to wrap five routes at the top of the file, three in the middle, and two at the bottom and
      # have all of them included in the default sitemap.
      # Since all routes within a sitemap block will be marked with the same name, 
      # I am not keeping track of sitemaps being defined with or without a block, so, all I need to know is about one of them.
      unless sitemap_route.sitemap_with_block?
        sitemap_route.sitemap_with_block = true if block_given?
      end

      # DuckMap::SitemapControllerHelpers is a module that is included in SitemapBaseController and contains
      # methods such as sitemap_build, etc.  Define a method to handle the sitemap on DuckMap::SitemapControllerHelpers
      # so that method is visible to the default sitemap controller as well as any custom controllers that inherit from it.
      # originally, I was simply defining the method directly on SitemapBaseController, however, it was causing problems
      # during the development cycle of edit and refresh.  Defining methods here seemed to cure that problem.
      # for example, the default sitemap: /sitemap.xml will define a method named: sitemap
      # on the DuckMap::SitemapControllerHelpers module.
      unless DuckMap::SitemapControllerHelpers.public_method_defined?(name)
        DuckMap::SitemapControllerHelpers.send :define_method, name do

          if DuckMap::Config.attributes[:sitemap_content].eql?(:xml)

            sitemap_build

          end

          respond_to do |format|
            format.xml { render }
          end
        end
      end

      # determine if the sitemap definition included a block.
      if block_given?

        # the starting point would be after the current set of routes and would be length plus one.
        # however, the starting point index is the length of routes, since arrays are zero based.
        start_point = @set.routes.length

        # push a copy of the current filter settings onto an array.
        # this will allow you to specify criteria setting within a sitemap definition without affecting
        # the default settings after the block is finished executing.
        @set.sitemap_filters.push

        # yield to the block.  all standard route code should execute just fine and define namespaces, resource, matches, etc.
        yield

        total = run_filter(sitemap_route.sitemap_route_name, start_point)

        # knock the current filter setting off of the stack
        @set.sitemap_filters.pop

        DuckMap.logger.debug %(total routes filtered: #{@set.routes.length - start_point}  included? #{total})

        @set.routes.each do |route|
          DuckMap.logger.debug %(  Route name: #{route.name}) if route.sitemap_route_name.eql?(sitemap_route.sitemap_route_name)
        end

      end

      return nil
    end

    ##################################################################################
    def run_filter(sitemap_route_name = nil, start_point = 0)
      total = 0

      # assign the sitemap_route_name to the sitemap_route_name attribute of every route that has just been added during the execution of the above block.
      start_point.upto(@set.routes.length + 1) do |index|

        # this is where the actual filtering of routes occurs and is based on the current sitemap filter settings.
        # if the route passes the criteria, then, it is "marked" as part of the sitemap.
        # no need to evaluate it every time a sitemap is requested.  evaluate it now and mark it.
        unless @set.routes.routes[index].blank?
          if @set.routes.routes[index].sitemap_route_name.blank?
            @set.routes.routes[index].sitemap_route_name = sitemap_route_name
            @set.routes.routes[index].available = @set.include_route?(@set.routes.routes[index])
            total += @set.routes.routes[index].is_available? ? 1 : 0
          end
        end

      end

      return total
    end

  end

  ##################################################################################
  module MapperMethods
    extend ActiveSupport::Concern

    ##################################################################################
    # See {DuckMap::RouteFilter#blank_route_name blank_route_name}
    def allow_blank_route_name(value)
      @set.blank_route_name = value
    end

    ##################################################################################
    def clear_filters
      @set.sitemap_filters.clear_filters
    end

    ##################################################################################
    def clear_filter(section, key)
      @set.sitemap_filters.clear_filter(section, key)
    end

    ##################################################################################
    def exclude_actions(*args)
      args.insert(0, :actions)
      @set.sitemap_filters.exclude_filter(*args)
    end

    ##################################################################################
    def exclude_controllers(*args)
      args.insert(0, :controllers)
      @set.sitemap_filters.exclude_filter(*args)
    end

    ##################################################################################
    def exclude_names(*args)
      args.insert(0, :names)
      @set.sitemap_filters.exclude_filter(*args)
    end

    ##################################################################################
    def exclude_verbs(*args)
      args.insert(0, :verbs)
      @set.sitemap_filters.exclude_filter(*args)
    end

    ##################################################################################
    def include_actions(*args)
      args.insert(0, :actions)
      @set.sitemap_filters.include_filter(*args)
    end

    ##################################################################################
    def include_controllers(*args)
      args.insert(0, :controllers)
      @set.sitemap_filters.include_filter(*args)
    end

    ##################################################################################
    def include_names(*args)
      args.insert(0, :names)
      @set.sitemap_filters.include_filter(*args)
    end

    ##################################################################################
    def include_verbs(*args)
      args.insert(0, :verbs)
      @set.sitemap_filters.include_filter(*args)
    end

    ##################################################################################
    def reset_filters
      @set.sitemap_filters.reset
    end

  end

end
