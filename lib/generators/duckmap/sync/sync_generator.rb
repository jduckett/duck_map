require "rails/generators"

module Duckmap
  module Generators

    class SyncGenerator < Rails::Generators::Base

      class_option :verbose, desc: "Show all operations"

      def self.source_root
        File.join(File.dirname(__FILE__), "templates")
      end

      def build

        config = {}

        unless options[:verbose].blank?
          config[:verbose] = options[:verbose]
        end

        DuckMap::Sync.new.build(config)

      end

    end

  end
end
