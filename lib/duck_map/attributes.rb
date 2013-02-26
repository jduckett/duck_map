require 'active_support/concern'

module DuckMap

  ##################################################################################
  # This module has a single purpose.  To declare a class-level attribute using the Rails class_attribute method.
  # Also, we are using {ActiveSupport::Concern} and the included block.  This module is included in
  # {ActionController::Base}, so, every controller object will have the attribute.
  #
  # See {DuckMap::Attributes::ClassMethods#sitemap_attributes} for an explanation.
  module InheritableClassAttributes
    extend ActiveSupport::Concern

    ################################################################################
    included do 
      class_eval do

        class_attribute :sitemap_attributes_hash
        class_attribute :sitemap_attributes_defined

      end
    end

  end

  ##################################################################################
  # Module used to add Sitemap attributes to an object.
  module Attributes
    extend ActiveSupport::Concern

    ##################################################################################
    module ClassMethods

      ##################################################################################
      ## See {DuckMap::Attributes#is_sitemap_attributes_defined? is_sitemap_attributes_defined?}
      # @return [TrueClass, FalseClass]
      def is_sitemap_attributes_defined?

        if self.sitemap_attributes_defined.nil?
          self.sitemap_attributes_defined = false
        end

        return self.sitemap_attributes_defined
      end

      ##################################################################################
      # Returns the entire attributes Hash that has been defined for an object.  The actual Hash is maintained via an accessor method named: sitemap_attributes_hash.
      # {#sitemap_attributes sitemap_attributes} is actually a wrapper method for sitemap_attributes_hash accessor method.
      #
      # There are actually two definitions of sitemap_attributes_hash accessor method.  The purpose of two definitions is to allow common code
      # contained in {DuckMap::Attributes} to be included in the {DuckMap::Config} and all controller classes.  The code works by referencing
      # sitemap_attributes_hash accessor method, however, the actual variable reference is different depending on the object that is referring to it.
      #
      # When {DuckMap::Attributes} module is included in {DuckMap::Config}, then, self.sitemap_attributes_hash is actually referencing the class
      # level method defined on {DuckMap::Config}.
      #
      # When {DuckMap::Attributes} module is included in all controller classes (it is by default), then, self.sitemap_attributes_hash
      # is actually referencing the class level method defined by {DuckMap::InheritableClassAttributes} via class_attribute method.
      # This means that the actual variable that will contain the Hash value never gets initialized.  So, self.sitemap_attributes_hash
      # will ALWAYS be uninitialized during the first access from within a controller and will ALWAYS copy values from {DuckMap::Config}.
      #
      # @return [Hash]
      def sitemap_attributes

        # check the current state of self.sitemap_attributes_hash.  If it is a Hash, then, it is considered initialized.
        # otherwise, a new Hash is populated and assigned to self.sitemap_attributes_hash and a reference is returned.
        #
        # when this module is included in DuckMap::Config self.sitemap_attributes_hash is actually referencing the class
        # level method defined on DuckMap::Config.
        #
        # When this module is included in all controller classes self.sitemap_attributes_hash is actually referencing the class
        # level method defined on InheritableClassAttributes which never gets initialized.  So, self.sitemap_attributes_hash
        # will NEVER be a Hash on the first access from within a controller and will ALWAYS copy values from {DuckMap::Config}
        unless self.sitemap_attributes_hash.kind_of?(Hash)

          # I actually have code to do a deep clone of a Hash, however, I can't release it right now.
          # I will in a later release.  For now, I will commit another sin.
          self.sitemap_attributes_hash = {}

          source = DuckMap::Config.sitemap_attributes_hash

          source.each do |item|
            self.sitemap_attributes_hash[item.first] = {}.merge(item.last)
            self.sitemap_attributes_hash[item.first][:handler] = {}.merge(item.last[:handler])
          end

        end

        return self.sitemap_attributes_hash
      end

    end

    ##################################################################################
    # This is a simple boolean value with a specific purpose.  It is used to indicate if the object
    # being worked on actually defined attributes using {DuckMap::SitemapObject::ClassMethods#acts_as_sitemap acts_as_sitemap},
    # {DuckMap::SitemapObject::ClassMethods#sitemap_handler sitemap_handler} or {DuckMap::SitemapObject::ClassMethods#sitemap_segments sitemap_segments}
    #
    # This has special meaning for ActiveRecord::Base objects.  When {DuckMap::Handlers handler methods} evaluate a model, the model is asked
    # if it defined it's own attributes.
    #
    # If the model did define it's own attributes, then, those attributes are used and override any attributes
    # set via acts_as_sitemap, sitemap_handler, or sitemap_segments on the controller.
    #
    # If the model did not define it's own attributes, then, the attributes defined on the controller are used.
    #
    # Defaults from {DuckMap::Config} are used if neither controller nor model defined any attributes.
    #
    # @return [TrueClass, FalseClass]
    def is_sitemap_attributes_defined?
      return self.class.is_sitemap_attributes_defined?
    end

    ##################################################################################
    # Returns a Hash associated with a key.  The Hash represents all of the attributes for
    # a given action name on a controller.
    #
    #     acts_as_sitemap :index, title: "my title"   # index is the key
    #     sitemap_attributes("index")                 # index is the key
    #
    # @return [Hash]
    def sitemap_attributes(key = :default)
      key = key.blank? ? :default : key.to_sym

      # if the key exists and has a Hash value, cool.  Otherwise, go back to :default.
      # self.class.sitemap_attributes should ALWAYS return a Hash, so, no need to test for that.
      # however, key may or may not be a Hash.  should test for that.
      unless self.class.sitemap_attributes[key].kind_of?(Hash)
        key = :default
      end

      # the :default Hash SHOULD ALWAYS be there.  If not, this might cause an exception!!
      return self.class.sitemap_attributes[key]
    end

    ##################################################################################
    # Wrapper method for {#sitemap_attributes sitemap_attributes} that returns a Hash stripped of key/value pairs
    # where the value is another Hash.
    #
    #     # normal
    #     values = sitemap_attributes("index")
    #     puts values #=> {:title=>:title, :keywords=>:keywords,
    #                 #    :description=>:description, :lastmod=>:updated_at,
    #                 #    :handler=>{:action_name=>:sitemap_index, :first_model=>true}}
    #
    #     # stripped
    #     values = sitemap_stripped_attributes("index")
    #     puts values #=> {:title=>:title, :keywords=>:keywords,
    #                 #    :description=>:description, :lastmod=>:updated_at}
    #
    # @return [Hash]
    def sitemap_stripped_attributes(key = :default)
      values = {}

      attributes = self.sitemap_attributes(key)
      attributes.each do |pair|

        # we are traversing a Hash in this loop.
        # each item passed to the block is a two-element Array.
        # the first element is a key and the second element is the value.
        # given: {title: :my_title, handler: {action_name: :sitemap_index}}
        # :title would be pair.first
        # :my_title would be pair.last
        # in the second case:
        # :handler would be pair.first
        # the Hash {action_name: :sitemap_index} would be pair.last
        # we want to skip all the dark meat and keep the white meat.
        # therefore, we are only interested in attributes that are on the first level.
        # meaning, simple key/value pairs where the value is a value other than Hash.
        unless pair.last.kind_of?(Hash)
            values[pair.first] = pair.last
        end

      end

      return values
    end

  end

end
