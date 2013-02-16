require "rails/generators"

module Duckmap
  module Generators

    class StaticGenerator < Rails::Generators::Base

      argument :key,
                banner: "[sitemap route name]",
                desc: "[sitemap route name]",
                default: :all,
                required: false,
                optional: true

      class_option :compression,    desc: "Indicates if the generated file(s) should be compressed"
      class_option :static_host,    desc: "Static hostname to use when building <url><loc> nodes"
      class_option :static_port,    desc: "Static port to use when building <url><loc> nodes"
      class_option :static_target,  desc: "Target base directory to write sitemap files."

      def self.source_root
        File.join(File.dirname(__FILE__), "templates")
      end

      def build

        config = {key: key}

        unless options[:compression].blank?
          config[:compression] = options[:compression]
        end

        unless options[:static_host].blank?
          config[:static_host] = options[:static_host]
        end

        unless options[:static_port].blank?
          config[:static_port] = options[:static_port]
        end

        unless options[:static_target].blank?
          config[:static_target] = options[:static_target]
        end

        DuckMap::Static.new.build(config)

      end

    end

  end
end
