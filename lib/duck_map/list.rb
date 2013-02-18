module DuckMap

  ##################################################################################
  # Lists all of the sitemaps defined in config/routes.rb
  class List

    ##################################################################################
    def build(options = {})

      key = options[:key].blank? ? :all : options[:key].to_s.downcase.to_sym

      contents = options.has_key?(:contents) ? true : false

      contents = key.eql?(:all) ? contents : true

      puts "Searching for route: #{key}"

      routes = []
      if key.eql?(:all)

        routes = Rails.application.routes.sitemap_routes_only

      else

        route = Rails.application.routes.find_route_via_name("#{key}_sitemap")
        if route.blank?
          puts "Unable to find route: #{key}"
        else
          routes.push(route)
        end

      end

      if routes.length > 0

        puts "\r\n\r\nSitemap routes"
        puts %(#{"route name".ljust(40)} controller_name#action_name)
        puts %(#{"".ljust(40)} path)
        puts "---------------------------------------------------------------------------------------------------------------"

        routes.each do |route|

          default_route = !route.name.blank? && route.name.to_sym.eql?(:sitemap_sitemap) ? " (DEFAULT)" : ""

          puts %(\r\n#{(route.name.blank? ? "".ljust(40) : "#{route.name}#{default_route}".ljust(40))} #{route.controller_name}##{route.action_name})

          puts %(#{"".ljust(40)} #{route.path.spec})

          if contents

            sitemap_routes = Rails.application.routes.sitemap_routes(route)
            if sitemap_routes.length > 0

              puts %(#{"".ljust(5)} --------------------------------------------------------------)

              sitemap_routes.each do |sitemap_route|

                puts %(#{"".ljust(5)} #{(sitemap_route.name.blank? ? "".ljust(34) : "#{sitemap_route.name}".ljust(34))} #{sitemap_route.controller_name}##{sitemap_route.action_name})

                puts %(#{"".ljust(40)} #{sitemap_route.path.spec})

              end

            else
              puts %(#{"".ljust(10)} No routes)
              puts %(#{"".ljust(10)} ----------------------------------------------)
            end

          end

        end

      else
        puts "Sorry, no routes found..."
      end

    end

  end

end
