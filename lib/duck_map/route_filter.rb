require 'active_support/concern'

module DuckMap

  class DuckmapExclude < StandardError
  end

  class DuckmapInclude < StandardError
  end

  class ExplicitExclude < StandardError
  end

  class ExplicitInclude < StandardError
  end

  class RouteNameMissing < StandardError
  end

  ##################################################################################
  # Mixin module for ActionDispatch::Routing::RouteSet.  This module is responsible for evaluating each route
  # for consideration to be included in a sitemap.
  module RouteFilter
    extend ActiveSupport::Concern

    # Indicates to the route filter to exclude / include routes that are missing names.
    attr_accessor :blank_route_name

    ##################################################################################
    # Indicates to the route filter to exclude / include routes that are missing names.
    # @return [Boolean]
    def blank_route_name?
      return self.blank_route_name.nil? ? false : self.blank_route_name
    end

    ##################################################################################
    # A Hash containing all of the values for exlude sitemap_filters.
    # @return [Hash]
    def sitemap_filters
      return @sitemap_filters ||= FilterStack.new
    end

    ##################################################################################
    # Determines if the current routes passes the current filter criteria.
    # @return [Boolean]  True if it passes, otherwise, false.
    def include_route?(route)
      value = false

      unless route.blank? || route.path.spec =~ %r{/rails/info/properties|^/assets}
        # this block looks very busy, but, actually all that is really going on here is we are matching
        # parts of the current route against sitemap_filter data configured via config/routes.rb, then,
        # raising and catching exceptions based on the outcome of each evaluation.
        # the rule is all routes excluded, unless included via some type of filter criteria.

        begin

          DuckMap.logger.debug "\r\n  Route: #{route.verb_symbol} #{route.route_name.ljust(30)} #{route.controller_name} => #{route.action_name}"
          DuckMap.logger.debug route
          DuckMap.logger.debug %(#{"Path:".rjust(30)} #{route.path.spec})

          # we don't want to include routes without a name.
          if route.name.blank?
            unless self.blank_route_name?
              raise RouteNameMissing, "route name blank"
            end
          end

          if match_any?(route.action_name, route.exclude_actions) ||
              match_any?(route.controller_name, route.exclude_controllers) ||
              match_any?(route.name, route.exclude_names) ||
              match_any?(route.verb_symbol, route.exclude_verbs)

            raise DuckmapExclude, "exclude"

          end

          if match_any?(route.action_name, route.include_actions) ||
              match_any?(route.controller_name, route.include_controllers) ||
              match_any?(route.name, route.include_names) ||
              match_any?(route.verb_symbol, route.include_verbs)

            raise DuckmapInclude, "include"

          end

          if match_any?(route.action_name, self.sitemap_filters.current_filter[:exclude][:actions])
            raise ExplicitExclude, "exclude"
          end

          if match_any?(route.verb_symbol, self.sitemap_filters.current_filter[:exclude][:verbs])
            raise ExplicitExclude, "exclude"
          end

          if match_any?(route.controller_name, self.sitemap_filters.current_filter[:exclude][:controllers])
            raise ExplicitExclude, "exclude"
          end

          if match_any?(route.name, self.sitemap_filters.current_filter[:exclude][:names])
            raise ExplicitExclude, "exclude"
          end

          if match_any?(route.action_name, self.sitemap_filters.current_filter[:include][:actions])
            raise ExplicitInclude, "include"
          end

          if match_any?(route.verb_symbol, self.sitemap_filters.current_filter[:include][:verbs])
            raise ExplicitInclude, "include"
          end

          if match_any?(route.controller_name, self.sitemap_filters.current_filter[:include][:controllers])
            raise ExplicitInclude, "include"
          end

          if match_any?(route.name, self.sitemap_filters.current_filter[:include][:names])
            raise ExplicitInclude, "include"
          end

        rescue DuckmapExclude => e
          DuckMap.logger.debug %(#{"Duckmap Exclude".rjust(30)} -> #{e})

          if match_any?(route.action_name, route.include_actions) ||
              match_any?(route.controller_name, route.include_controllers) ||
              match_any?(route.name, route.include_names) ||
              match_any?(route.verb_symbol, route.include_verbs)

            DuckMap.logger.debug %(#{"Duckmap Exclude".rjust(30)} -> included again...)
            value = true
          end

        rescue DuckmapInclude => e
          DuckMap.logger.debug %(#{"Duckmap Include".rjust(30)} -> #{e})
          value = true

        rescue ExplicitExclude => e
          DuckMap.logger.debug %(#{"Explicit Exclude".rjust(30)} -> #{e})

        rescue ExplicitInclude => e
          DuckMap.logger.debug %(#{"Explicit Include".rjust(30)} -> #{e})
          value = true

        rescue RouteNameMissing => e
          DuckMap.logger.debug %(#{"Route Name Missing".rjust(30)} -> #{e})

        rescue Exception => e
          DuckMap.logger.info %(#{"Unknown Exception".rjust(30)} -> #{e})
          DuckMap.logger.info e.backtrace.join("\r\n")
        end

      end

      return value
    end

    ##################################################################################
    # Matches a single value against an array of Strings, Symbols, and Regexp's.
    # @param [String] data    Any value as a String to compare against any of the Strings, Symbols, or Regexp's in the values argument.
    # @param [Array] values   An array of Strings, Symbols, or Regexp's to compare against the data argument.  The array can be a mix of all three possible types.
    # @return [Boolean] True if data matches any of the values or expressions in the values argument, otherwise, false.
    def match_any?(data = nil, values = [])

      unless data.blank?

        unless values.kind_of?(Array)
          # wow, this worked!!??
          # values was not an array, so, add values to a new array and assign back to values
          values = [values]
        end

        values.each do |value|

          if value.kind_of?(String) && (data.to_s.downcase.eql?(value.downcase) || value.eql?("all"))
            return true

          elsif value.kind_of?(Symbol) && (data.downcase.to_sym.eql?(value) || value.eql?(:all))
            return true

          elsif value.kind_of?(Regexp) && data.match(value)
            return true

          end
        end

      end

      return false
    end

  end
end
