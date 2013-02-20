require "rails/generators"

module Duckmap
  module Generators

    class SitemapsGenerator < Rails::Generators::Base

      argument :key,
                banner: "[sitemap route name]",
                desc: "[sitemap route name]",
                default: :all,
                required: false,
                optional: true

      class_option :verbose, desc: "Include the routes contained in a sitemap"

      def self.source_root
        File.join(File.dirname(__FILE__), "templates")
      end

      def build

        config = {key: key}

        unless options[:verbose].blank?
          config[:verbose] = options[:verbose]
        end

        DuckMap::List.new.build(config)

      end

    end

  end
end
