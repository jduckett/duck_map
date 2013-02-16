# DONE
require 'active_support/concern'

module DuckMap

  ##################################################################################
  # Model has a very specific purpose.  To hold the Array of Hash objects that represent
  # the contents of a single sitemap.
  module Model
    extend ActiveSupport::Concern

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

  end

end
