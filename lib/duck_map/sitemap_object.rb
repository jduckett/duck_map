require 'active_support/concern'

module DuckMap

  ##################################################################################
  # Module used to add Sitemap methods and attributes to an object.
  module SitemapObject
    extend ActiveSupport::Concern

    ##################################################################################
    module ClassMethods

      ##################################################################################
      # @note The syntax is always the same regardless if you define acts_as_sitemap in config/routes.rb or directly
      #       on a controller or model.
      #
      # Sets default values, attributes and mappings for sitemap objects.  All SitemapObject attributes are maintained
      # in a master Hash.  Attributes for each action are stored in the master Hash and accessed via action_name as the key.
      #
      # All attributes are broken into two categories.
      # - Configuration level: These attributes are defined within the config/routes.rb block and are considered
      #   global default values for ALL sitemap related classes and objects.
      # - Controller level: These attributes are exactly the same as Configuration level with one difference.
      #   They apply to each controller class ONLY.  Setting attributes at the controller level will make a copy
      #   of the Configuration level attributes and merge with the values you pass to {#acts_as_sitemap acts_as_sitemap}.
      #
      # When a sitemap is created or meta tag data is needed, the controller is "asked" to provide the required data
      # for a specific action on the controller.  The mechanism that makes the request is called a "handler".  Handlers
      # are mapped to standard Rails controller actions.
      # - The index action is mapped to sitemap_index.
      # - The show action is mapped to sitemap_show.
      #
      # Attributes have two meanings:
      # - If the attribute value is set to a Symbol, then, it is considered to point to an attribute/method name of the target SitemapObject (self).
      # - If the attribute value is set to anything other than a Symbol, then, the value is used "as is".
      #
      # In the example below, we are setting meta data attributes.
      #
      #     acts_as_sitemap :index, title: "List of my pages..."    #=> static title for the index page.
      #     acts_as_sitemap :edit,  title: :title                   #=> returns the value of the title attribute/method.
      #     acts_as_sitemap :new,   title: "New page"               #=> static title for the new page.
      #     acts_as_sitemap :show,  title: :title                   #=> returns the value of the title attribute/method.
      #
      # Here, we are setting sitemap attributes.
      #
      #     acts_as_sitemap :index, changefreq: "always",   priority: "1.0"
      #     acts_as_sitemap :edit,  changefreq: "never",    priority: "0.0"
      #     acts_as_sitemap :new,   changefreq: "never",    priority: "0.0"
      #     acts_as_sitemap :show,  changefreq: "monthly",  priority: "7.0"
      #
      #     # here we are telling ALL handlers to get the last modified date
      #     # for a sitemap and meta tag from 
      #     acts_as_sitemap lastmod: :last_updated_at
      #
      # The sitemap / meta tag {DuckMap::Handlers handlers} will attempt to extract attributes values from the first model
      # found on a controller.  To make meeting special needs a little easier, you can use a block to return a single model
      # or an Array of model objects to include in your sitemap.
      #
      # This example is worth a few extra words.
      # - When building a sitemap for the index action of a controller, you only need to build one url.
      # - When building a sitemap for the show action of a controller, you will typically need to build an entire set of urls to represent
      #   the rows in your table.  However, when showing the meta tag data, you will need the attributes from the specific model for the current
      #   page.
      #
      #     acts_as_sitemap :index do
      #       Book.where(title: "my latest book").first
      #     end
      #
      #     acts_as_sitemap :show do
      #       Book.all
      #     end
      #
      # Let's say you the show action of your controller just won't fit into the standard behavior
      # and you need to build the url using a custom method.  Simply build the method on your object and point to it.
      #
      #     acts_as_sitemap :show, canonical: :my_special_method
      #
      # The full syntax would include handlers and segments.
      #
      #     acts_as_sitemap :index, title: "My App",
      #                             changefreq: "always",
      #                             priority: "1.0",
      #                             handler: {action_name: :my_index, first_model: false},
      #                             segments: {id: :my_id, sub_id: :belongs_to_id}
      #
      # However, there are convenience methods to make things a little cleaner.
      #
      #     acts_as_sitemap  :index, title: "My App", changefreq: "always", priority: "1.0"
      #     sitemap_handler  :index, action_name: :my_index, first_model: false
      #     sitemap_segments :index, id: :my_id, sub_id: :belongs_to_id
      #
      # So far, we have only discussed the attributes that are used by the standard {DuckMap::Handlers handlers}.  However,
      # you do have the option of building and using your own handlers to meet special needs or to completely change the default
      # behavior of ALL handlers.  Let's say the default behavior for the {DuckMap::Handlers::Index index handler} does not meet your
      # needs.  You could build your own index handler and set it in the config/routes.rb
      #
      #     MyApp::Application.routes.draw do
      #
      #       # defining attributes in config/routes.rb are used globally
      #       # your action handler method will be used throughout the entire app.
      #       # simply create your own handler method and make it accessible to every controller
      #       # in your app.  Maybe include in your ApplicationController or something.
      #       sitemap_handler :index, action_name: :my_index
      #
      #     end
      #
      # @overload acts_as_sitemap(action_name = nil, options = {}, &block)
      #   @param [String, Symbol] action_name           The action name is used as a key when looking for attributes.
      #                                                 When sitemap or meta tag needs data for the index action it
      #                                                 will use :index as the key.  Omitting the action_name will
      #                                                 default to :all which will assign the values you pass to "all"
      #                                                 actions for the controller.
      #                                                 
      #                                                 
      #   @param [Hash] options                         Options hash.
      #                                                 - Setting to a Symbol will attempt to access attribute method name on the SitemapObject itself.
      #                                                 - Setting to any value other than a Symbol will use that value "as is".
      #   @option options [Symbol] :canonical           Default value: nil
      #   @option options [Symbol] :canonical_host      Default value: nil
      #   @option options [Symbol] :changefreq          Valid static values are:
      #                                                 - always
      #                                                 - hourly
      #                                                 - daily
      #                                                 - weekly
      #                                                 - monthly
      #                                                 - yearly
      #                                                 - never
      #   @option options [Symbol] :description         Default value: :description
      #   @option options [Symbol] :handler             Sub-hash containing attributes for the handler.  See {#sitemap_handler sitemap_handler}
      #   @option options [Symbol] :keywords            Default value: :keywords
      #   @option options [Symbol] :lastmod             Default value: :updated_at
      #   @option options [Symbol] :priority            Valid static values range from 0.0 to 1.0
      #   @option options [Symbol] :segments            Sub-hash containing attributes for the segments.  See {#segments_handler segments_handler}
      #   @option options [Symbol] :title               Default value: :title
      #   @option options [Symbol] :url_format          Default value: "html"
      #   @option options [Symbol] :url_limit           Default value: 50000
      #
      #   @param [Block] block                          A block to assign to all handlers associated with action_name.  The
      #                                                 block should return an Array of ActiveRecord::Base models.  The model objects
      #                                                 server as sitemap content for the given action name.
      #   @return [Nil]
      def acts_as_sitemap(*args, &block)
        key = :all

        self.sitemap_attributes_defined = true

        if args.length > 0

          if args.first.kind_of?(Symbol)
            key = args.shift

          elsif args.first.kind_of?(String)
            key = args.shift.to_sym

          end

        end

        values = args.first.kind_of?(Hash) ? args.first : {}

        # delete method should always return nil if the key doesn't exist
        handler = values.delete(:handler)
        segments = values.delete(:segments)

        # i'm going to verify and set a default anyway
        handler = handler.kind_of?(Hash) ? handler : {}

        segments = segments.kind_of?(Hash) ? segments : {}

        # build a list of keys to work on
        # developer can specify :all, which will build a list of all the existing keys in the Hash
        # otherwise, it will just use the key passed to acts_as_sitemap
        keys = []
        if key == :all
          self.sitemap_attributes.each {|pair| keys.push(pair.first)}
        else
          keys.push(key)
        end

        if values[:lastmod].kind_of?(String)
          begin

            buffer = LastMod.to_date(values[:lastmod])
            if buffer.kind_of?(Time)
              values[:lastmod] = buffer
            end

          rescue Exception => e
            # TODO logging
          end
        end

        # process all of the keys in the list.
        keys.each do |key|

          # create defaults unless they exist
          unless self.sitemap_attributes[key].kind_of?(Hash)
            self.sitemap_attributes[key] = {}
          end

          unless self.sitemap_attributes[key][:handler].kind_of?(Hash)
            self.sitemap_attributes[key][:handler] = {}
          end

          unless self.sitemap_attributes[key][:segments].kind_of?(Hash)
            self.sitemap_attributes[key][:segments] = {}
          end

          # merge the main hash.
          self.sitemap_attributes[key].merge!(values)

          # merge the handler
          #unless handler.blank?
          if handler.kind_of?(Hash)

            if block_given?

              handler[:block] = block
            end

            self.sitemap_attributes[key][:handler].merge!(handler)

          end

          # merge the segments
          unless segments.blank?

            self.sitemap_attributes[key][:segments].merge!(segments)

          end

        end

        return nil
      end

      ##################################################################################
      # @note See {DuckMap::Handlers} for specific details on how each one of these attributes
      #       are utilized by each handler.
      #
      # Wrapper for {#acts_as_sitemap acts_as_sitemap} and accepts the same exact arguments.
      # Basically, sitemap_handler simplifies the syntax needed to define a handler
      # for all or a specific action.
      #
      #    sitemap_handler :index, action_name: :my_index, first_model: false
      #
      #    # is equivalent to:
      #    acts_as_sitemap :index, handler: {action_name: :my_index}
      #
      #    sitemap_handler :index, instance_var: :my_var
      #    sitemap_handler :index, instance_var: "my_var"
      #
      #    sitemap_handler :index, model: Book
      #    sitemap_handler :index, model: "Book"
      #
      #
      # @overload sitemap_handler(action_name = nil, options = {}, &block)
      #   @param [String, Symbol] action_name    The action name.  See {#acts_as_sitemap acts_as_sitemap}
      #   @param [Hash] options                  Options hash.
      #   @option options [Symbol] :action_name  The method name to call.  Method name MUST exist on your object!
      #   @option options [Symbol] :first_model  Boolean.  Tells the handler to get values from the first available
      #                                          model object found on the controller.
      #   @option options [Symbol] :instance_var The model
      #   @option options [Symbol] :model        A model object expressed as a String or an actual class reference.
      #                                          See {DuckMap::Handlers} for details on how this attribute is utilized.
      # @return [NilClass]
      def sitemap_handler(*args, &block)
        key = args.first.kind_of?(Symbol) ? args.shift : :all
        options = args.first.kind_of?(Hash) ? args.shift : {}
        options = args.last.kind_of?(Hash) ? args.pop : options
        return self.acts_as_sitemap(key, handler: options, &block)
      end

      ##################################################################################
      # Wrapper for {#acts_as_sitemap acts_as_sitemap} and accepts the same exact arguments.
      # Basically, sitemap_segments simplifies the syntax needed to define segments
      # for all or a specific action.
      #
      #    sitemap_segments :index, id: :my_id
      #
      #    # is equivalent to:
      #    acts_as_sitemap :index, segments: {id: :my_id}
      #
      # @return [NilClass]
      def sitemap_segments(*args, &block)
        key = args.first.kind_of?(Symbol) ? args.shift : :all
        options = args.first.kind_of?(Hash) ? args.shift : {}
        options = args.last.kind_of?(Hash) ? args.pop : options
        return self.acts_as_sitemap(key, segments: options, &block)
      end

    end

    ##################################################################################
    # Returns a Hash containing key/value pairs from the current object.
    #
    # This method loops through all of the key/value pairs contained in the attributes Hash.
    #
    # Each pair is inspected.
    # - if the value is a Symbol
    #   - the current object is asked if it has a matching method name matching the value.
    #     - if true, then, the method is called to obtain a value.
    #       - if the new value is NOT nil, then, it is paired with the key of the current pair being processed
    #         and assigned to the returning Hash.
    # - otherwise, if the value is not nil, then, it is considered to be a static value and is assigned to the
    #   returning Hash using the key of the current pair being processed.
    #
    #    # let's pretend this class exists and has the following attributes.
    #    object = MyObject.new
    #    object.my_title = "my title"
    #    object.tags = "this that other"
    #    object.content = "this is a test"
    #    object.last_updated_at = Time.now
    #
    #    attributes = {title: :my_title,
    #                  keywords: nil,
    #                  description: "this is my desc",
    #                  lastmod: :invalid_method_name}
    #
    #    values = object.sitemap_capture_attributes(attributes)
    #
    #    puts YAML.dump values        # => {title => "my title", description => "this is my desc"}
    #
    # The result:
    # - :my_title is a Symbol and attribute exists on object and value is not nil, so, it is included in the returning Hash.
    # - :keywords is nil, so, it is ignored and not included in the returning Hash.
    # - :description is a String and considered a static value, so, it is included in the returning Hash "as is".
    # - :my_title is a Symbol, however, a matching attribute/method does NOT exist on the target object, so,
    #   it is ignored and not included in the returning Hash.
    #
    # @param [Hash] options                  Options hash. Can be any combination of key/value pairs (one-dimensional).
    # return [Hash]
    def sitemap_capture_attributes(attributes = {})
      values = {}

      attributes.each do |pair|

        # if the value of the pair is a Symbol, then, it is implied to be
        # an attribute of the object we are working on.
        # therefore, we will attempt to get the value of that attribute from the object.
        if pair.last.kind_of?(Symbol)

          # if the object has the attribute/method we are looking for, then, capture the value
          # by calling the attribute/method and assign the return value to the return Hash
          # using pair.first as the key.
          if self.respond_to?(pair.last)

            # ask the object for the attribute value
            value = self.send(pair.last)

            # ignore nil values
            unless value.blank?
              values[pair.first] = value
            end

          end

        elsif !pair.last.blank?
          values[pair.first] = pair.last
        end

      end

      return values
    end

    ##################################################################################
    # Segment keys are placeholders for the values that are plugged into a named route when it is constructed.
    #
    # The following Rails route has a two segment keys: :id and :format.
    #
    #     book GET    /books/:id(.:format)   books#show
    #
    # :id is the row.id of a Book and :format is the extension to be used when constructing a path or url.
    # 
    #     book_path(1)                      #=> /book/1
    #     book_path(1, "html")              #=> /book/1.html
    #     book_path(id: 1, format: "html")  #=> /book/1.html
    #     book_path(id: 2, format: "xml")   #=> /book/2.xml
    #
    # sitemap_capture_segments attempts to populate a Hash with values associated with the required segment keys.
    #
    #     row = Book.create(title: "Duck is a self-proclaimed resident moron...")
    #     puts row.id                                #=> 1
    #     row.sitemap_capture_segments(nil, [:id])   #=> {:id => 1}
    #
    # You have the ability to map attributes of an object to segment keys.  This could be useful for routes
    # that do not follow standard convention or cases where you have some deeply nested resources.
    #
    #     class BooksController < ApplicationController
    #       sitemap_segments :show, id: :my_id
    #     end
    #
    #     class Book < ActiveRecord::Base
    #       attr_accessible :my_id, :author, :title
    #
    #       before_save :generate_my_id
    #
    #       def generate_my_id
    #         # do some magic
    #         self.my_id = 2
    #       end
    #
    #     end
    #
    #     row = Book.create(title: "Please ignore the first title :)")
    #     puts row.id                                #=> 1
    #     puts row.my_id                             #=> 2
    #     # normally, you would get the attributes via:
    #     # controller.sitemap_attributes("show")[:segments]
    #     attributes = {id: :my_id}
    #     row.sitemap_capture_segments(attributes, [:id])   #=> {:id => 2}
    #
    # Segment values are obtained in two stages.
    # - Stage one asks the current object (controller or model) for attributes from segment_mappings and
    #   places those key/values in the returning hash.
    #
    # - Stage two asks the current object (controller or model) for attributes from segments array
    #   that have not already been found via segment_mappings and places those key/values in the returning hash.
    #
    # @param [Hash] segment_mappings    A Hash containing one-to-one attribute mappings for segment keys to object attributes.
    # @param [Array] segments           The segments Array of a Rails Route.
    # return [Hash]
    def sitemap_capture_segments(segment_mappings = {}, segments = [])
      values = {}

      # do nothing if there are no segments to work on
      if segments.kind_of?(Array)

        # first, look for mappings
        unless segment_mappings.blank?
          segments.each do |key|

            attribute_name = segment_mappings[key.to_sym].blank? ? key : segment_mappings[key.to_sym]

            if self.respond_to?(attribute_name)
              values[key] = self.send(attribute_name)
            end

          end
        end

        # second, look for attributes that have not already been found.
        segments.each do |key|

          unless values.has_key?(key)
            if self.respond_to?(key)
              values[key] = self.send(key)
            end
          end

        end

      end

      return values
    end

  end
end









