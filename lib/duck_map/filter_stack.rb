# DONE
require 'active_support/concern'

module DuckMap

  ##################################################################################
  class FilterStack

    #DEFAULT_FILTER = {actions: [:new, :create, :edit, :update, :destroy],
                        #verbs: [:post, :put, :delete], names: [], controllers: []}
    DEFAULT_FILTER = {actions: [:index, :show], verbs: [], names: [], controllers: []}

    ##################################################################################
    def initialize
      super
      self.reset
    end

    ##################################################################################
    # A Hash containing all of the values for exlude sitemap_filters.
    # @return [Hash]
    def stack
      return @stack ||= []
    end

    ##################################################################################
    # Sets the entire Hash for exclude sitemap_filters.
    # @return [Nil]
    def stack=(value)
      @stack = value
    end

    ##################################################################################
    # Resets the stack.
    # @return [NilClass]
    def reset
      self.stack = [copy_filter(DEFAULT_FILTER)]
    end

    ##################################################################################
    # Copies a filter
    # @return [Hash]
    def copy_filter(filter)
      buffer = {}
      filter.each do |part|
        buffer[part[0]] = part[1].dup
      end
      return buffer
    end

    ##################################################################################
    # Pushes a copy of the current filter onto the end of the stack.
    # @return [Hash]
    def push
      self.stack.push(copy_filter(self.current_filter))
    end

    ##################################################################################
    # Pops the last item from the stack.  However, the list can never be empty, so, it pops
    # the last item ONLY if the stack has more than ONE item.
    # @return [Hash]
    def pop
      return self.stack.length > 1 ? self.stack.pop : self.current_filter
    end

    ##################################################################################
    # Returns the current filter.  The current filter is ALWAYS the last item in the stack.
    # @return [Hash]
    def current_filter
      return self.stack.last
    end

    ##################################################################################
    # Sets the entire Hash for the {#current_filter}.
    # @return [NilClass]
    def current_filter=(value)
      self.stack.pop
      self.stack.push(value)
      return nil
    end

    ##################################################################################
    # Adds a value(s) to the {#current_filter}.  The filter stack is implemented as an Array of Hashes.
    # The {#current_filter} will always be a Hash of key/value pairs.  Each key represents a type of filter:
    #
    # The filter types are:
    # - :actions
    # - :verbs
    # - :names
    # - controllers
    #
    # Each key has an associated Array of Strings or Symbols.  The default filter is:
    #
    #     {actions: [:index, :show], verbs: [:get], names: [], controllers: []}
    #
    # The default is to include all routes that have an :action of :index or :show or include routes that have
    # a verb of :get.  Basically, including urls that a search engine would crawl.
    # The Array of values added to the filter can be mixed. However, the convention is to use Symbols for
    # :actions and :verbs and use Strings for :names and :controllers.  Values are automagically converted to Symbols
    # if the key is :actions or :verbs.
    #
    #     include_filter(:actions, :edit)              # => {actions: [:index, :show, :edit], verbs: [:get], names: [], controllers: []}
    #     include_filter(:actions, [:edit, :update])   # => {actions: [:index, :show, :edit, :update], verbs: [:get], names: [], controllers: []}
    #     include_filter(:actions, "edit")             # => {actions: [:index, :show, :edit], verbs: [:get], names: [], controllers: []}
    #     include_filter(:actions, ["edit", "update"]) # => {actions: [:index, :show, :edit], verbs: [:get], names: [], controllers: []}
    #     include_filter(:actions, [:edit, "update"])  # => {actions: [:index, :show, :edit], verbs: [:get], names: [], controllers: []}
    #     include_filter(:verbs, :post)                # => {actions: [:index, :show], verbs: [:get, :post], names: [], controllers: []}
    #
    # @overload include_filter(key, value)
    #   @param [Symbol, String]        key   The type of filter to update. :actions, :verbs, :names, :controllers.
    #   @param [String, Symbol, Array] value A single or Array of items to be added to the filter section specified via key.
    # @return [NilClass]
    def include_filter(*args)
      args.insert(0, :include)
      return update_filter(*args)
    end

    ##################################################################################
    # Adds or removes value(s) to or from the {#current_filter}.  This method is called by {#include_filter} and {#exclude_filter}.
    # @overload update_filter(action, key, value)
    #   @param [Symbol, String]        action The action to perform:  :include or :exclude.
    #   @param [Symbol, String]        key    The type of filter to update. :actions, :verbs, :names, :controllers.
    #   @param [String, Symbol, Array] value  A single or Array of items to be added to the filter section specified via key.
    # @return [NilClass]
    def update_filter(*args)

      action = args.shift
      action = action.kind_of?(Symbol) ? action : action.to_sym

      key = args.shift
      key = key.kind_of?(Symbol) ? key : key.to_sym

      # list will always be concatenated to the target array
      list = []

      # build the list array depending on what the user passed to the method
      args.each do |item|
        if item.kind_of?(Array) && item.any?
          list.concat(item)
        else
          list.push(item)
        end
      end

      # convert all of the items in the list to symbols
      # for :actions or :verbs
      if key.eql?(:actions) || key.eql?(:verbs)
        list.each_with_index do |item, index|
          unless item.kind_of?(Symbol)
            list[index] = item.to_sym
          end
        end
      end

      if action == :include

        # now, simply concatenate the resulting list and make sure the final array is unique
        self.current_filter[key].concat(list)
        self.current_filter[key].uniq!

      elsif action == :exclude

        self.current_filter[key].reject! {|item| list.include?(item)}

      end

      return nil
    end

    ##################################################################################
    # Removes value(s) from the {#current_filter}.  Basically, the opposite of {#include_filter}.
    # @overload exclude_filter(key, value)
    #   @param [Symbol, String]        key    The type of filter to update. :actions, :verbs, :names, :controllers.
    #   @param [String, Symbol, Array] value  A single or Array of items to be added to the filter section specified via key.
    # @return [NilClass]
    def exclude_filter(*args)
      args.insert(0, :exclude)
      return update_filter(*args)
    end

    ##################################################################################
    # Clears all types (:actions, :verbs, :names, :controllers) for the {#current_filter}.
    # @return [Nil]
    def clear_filters
      self.current_filter = {actions: [], verbs: [], names: [], controllers: []}
      return nil
    end

    ##################################################################################
    # Clears a single type of filter.
    # @param [Symbol, String]        key    The type of filter to update. :actions, :verbs, :names, :controllers.
    # @return [Nil]
    def clear_filter(key)
      key = key.kind_of?(Symbol) ? key : key.to_sym
      self.current_filter[key] = []
      return nil
    end

  end
end
