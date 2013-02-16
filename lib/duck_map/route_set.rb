require 'active_support/concern'

module DuckMap

  ##################################################################################
  # Mixin module for ActionDispatch::Routing::RouteSet to add support for defining sitemaps directly
  # inside the config/routes.rb of a Rails app.
  module RouteSet
    extend ActiveSupport::Concern

    ##################################################################################
    # Builds a list of routes associated with a sitemap.  The actual list of routes returned is based
    # on {DuckMap::Sitemap::Route::InstanceMethods#sitemap_route_name sitemap_route_name}, which is the named route of the sitemap.
    # @note See {DuckMap::Sitemap::Mapper::InstanceMethods#sitemap} for a full explanation of how to define a sitemap and how those rules affect this method.
    # @param [String] name_or_path  The request.path of the current sitemap url or the name assigned to the sitemap via config/routes.rb.
    # @return [Array]
    def find_sitemap_route(name_or_path)

      name_or_path = name_or_path.to_s

      # strip off the extension if it exists
      if name_or_path.include?(".")
        name_or_path = name_or_path.slice(0, name_or_path.rindex("."))
      end

      full_name = "#{name_or_path}_sitemap"

      # search for a sitemap route matching the path passed to the method.
      # the route MUST be marked as a sitemap.  return nothing if the sitemap route cannot be found.
      return self.routes.find {|route| route.is_sitemap? &&
                                    (route.path.spec.to_s =~ /^#{name_or_path}/ ||
                                    route.sitemap_route_name.eql?(name_or_path) ||
                                    route.sitemap_route_name.eql?(full_name))}
    end

    ##################################################################################
    # Builds a list of routes associated with a sitemap route.  The actual list of routes returned is based
    # on {DuckMap::Sitemap::Route::InstanceMethods#sitemap_route_name sitemap_route_name}, which is the named
    # route of the sitemap.
    # @note See {DuckMap::Sitemap::Mapper::InstanceMethods#sitemap} for a full explanation of how to define a sitemap and how those rules affect this method.
    # @param [String] sitemap_route A sitemap route.
    # @return [Array]
    def sitemap_routes(sitemap_route)
      list = []

      if sitemap_route

        # if the sitemap defined within config/routes.rb included a block, then, return ALL of the rows associated with
        # sitemap route name.  Otherwise, return ALL routes that have NOT BEEN associated with any other sitemap.
        if sitemap_route.sitemap_with_block?

          # sitemap_route_name MUST MATCH
          #list = self.routes.find_all {|route| !route.is_sitemap? && route.sitemap_route_name.eql?(sitemap_route.sitemap_route_name)}
          list = self.routes.find_all do |route|
            !route.is_sitemap? && route.sitemap_route_name.eql?(sitemap_route.sitemap_route_name)
          end

        else

          candidates = self.routes.find_all {|route| !route.is_sitemap?}

          potential_owners = self.routes.find_all {|route| route.is_sitemap?}
          potential_owners.sort! { |a,b| b.namespace_prefix_underscores <=> a.namespace_prefix_underscores}

          candidates.each do |candidate|

            value = nil
            potential_owners.each do |owner|

              if (!candidate.sitemap_route_name.blank? && owner.sitemap_route_name.eql?(candidate.sitemap_route_name))

                value = owner
                break

              elsif (!owner.namespace_prefix.blank? &&
                      candidate.name =~ /^#{owner.namespace_prefix}/ &&
                      !owner.sitemap_with_block?)

                value = owner
                break
              end

              if value.blank?
                potential_owners.each do |owner|
                  if (owner.namespace_prefix.blank? && !owner.sitemap_with_block?)

                    value = owner
                    break

                  end
                end
              end

            end

            if !value.blank? && value.name.eql?(sitemap_route.name)
              list.push(candidate)
            end

          end

          list.reject! {|route| !self.include_route?(route)}

        end

      end

      return list
    end

    ##################################################################################
    def route_owner(route)
      value = nil

      potential_owners = self.routes.find_all {|route| route.is_sitemap?}
      potential_owners.sort! { |a,b| b.namespace_prefix_underscores <=> a.namespace_prefix_underscores}

      potential_owners.each do |owner|

        if (!route.sitemap_route_name.blank? && owner.sitemap_route_name.eql?(route.sitemap_route_name))
          value = owner
          break
        elsif !owner.namespace_prefix.blank? && route.name =~ /^#{owner.namespace_prefix}/
          value = owner
          break
        end

      end

      if value.blank?
        potential_owners.each do |owner|
          if owner.namespace_prefix.blank? && !owner.sitemap_with_block?
            value = owner
            break
          end
        end
      end

      return value
    end

    ##################################################################################
    def sitemap_routes_only
      return self.routes.find_all {|route| route.is_sitemap?}
    end

    ##################################################################################
    def find_route_via_name(name)
      return self.routes.find {|route| route.name.eql?(name)}
    end

    ##################################################################################
    def find_route_via_path(path, environment = {})
      method = (environment[:method] || "GET").to_s.upcase
      path = Journey::Router::Utils.normalize_path(path) unless path =~ %r{://}

      begin
        env = Rack::MockRequest.env_for(path, {:method => method})
      rescue URI::InvalidURIError => e
        raise ActionController::RoutingError, e.message
      end

      req = @request_class.new(env)
      @router.recognize(req) do |route, matches, params|
        params.each do |key, value|
          if value.is_a?(String)
            value = value.dup.force_encoding(Encoding::BINARY) if value.encoding_aware?
            params[key] = URI.parser.unescape(value)
          end
        end

        dispatcher = route.app
        #while dispatcher.is_a?(Mapper::Constraints) && dispatcher.matches?(env) do
        while dispatcher.is_a?(ActionDispatch::Routing::Mapper::Constraints) && dispatcher.matches?(env) do
          dispatcher = dispatcher.app
        end

        if dispatcher.is_a?(ActionDispatch::Routing::RouteSet::Dispatcher) && dispatcher.controller(params, false)
          dispatcher.prepare_params!(params)
          return route
        end
      end

      raise ActionController::RoutingError, "No route matches #{path.inspect}"
    end





  end

end
















