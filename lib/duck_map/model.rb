require 'active_support/concern'

module DuckMap

  ##################################################################################
  # Model has a very specific purpose.  To hold the Array of Hash objects that represent
  # the contents of a single sitemap.
  module Model
    extend ActiveSupport::Concern

    autoload :Supported, 'duck_map/model'

    ##################################################################################
    # Array containing all of the Hash objects that represent the contents of a single sitemap.
    # Originally, this method was part of {DuckMap::ControllerHelpers}, however, it was separated
    # and moved here to minimize the number of methods being added to controllers.
    # @return [Array]
    def sitemap_model
      @sitemap_model ||= []
    end

    def sitemap_model=(value)
      @sitemap_model = value
    end

    ##################################################################################
    class Supported

      ##################################################################################
      def self.models
        unless defined?(@@models)
          @@models = [ActiveRecord::Base, ActiveRecord::Relation]
        end
        return @@models
      end

      ##################################################################################
      def self.is_supported?(obj)
        value = false

        unless obj.blank?
          self.models.each do |model|
            if obj.kind_of?(model)
              value = true
              break
            end
          end
        end

        return value
      end

    end

  end

end
