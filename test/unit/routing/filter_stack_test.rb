require 'test_helper'

class FilterStackTest < ActiveSupport::TestCase

  test "default filter stack" do

    obj = DuckMap::FilterStack.new

    assert obj.stack.kind_of?(Array), "obj.stack SHOULD BE an array and is NOT"
    assert obj.stack.length > 0, "obj.stack SHOULD have at least one item"
    assert obj.stack.last.kind_of?(Hash), "obj.stack.last SHOULD BE a Hash"
    assert obj.current_filter.kind_of?(Hash), "obj.current_filter SHOULD BE a Hash"

    assert obj.current_filter[:exclude][:actions].kind_of?(Array), ":actions SHOULD be an array"
    assert obj.current_filter[:exclude][:actions].blank?, "SHOULD be an empty array"

    assert obj.current_filter[:exclude][:controllers].kind_of?(Array), ":controllers SHOULD be an array"
    assert obj.current_filter[:exclude][:controllers].blank?, "SHOULD be an empty array"

    assert obj.current_filter[:exclude][:names].kind_of?(Array), ":names SHOULD be an array"
    assert obj.current_filter[:exclude][:names].blank?, "SHOULD be an empty array"

    assert obj.current_filter[:exclude][:verbs].kind_of?(Array), ":verbs SHOULD be an array"
    assert obj.current_filter[:exclude][:verbs].include?(:delete), "SHOULD contain :delete"
    assert obj.current_filter[:exclude][:verbs].include?(:post), "SHOULD contain :post"
    assert obj.current_filter[:exclude][:verbs].include?(:put), "SHOULD contain :put"

    assert obj.current_filter[:include][:actions].kind_of?(Array), ":actions SHOULD be an array"
    assert obj.current_filter[:include][:actions].include?(:index), "SHOULD contain :index"
    assert obj.current_filter[:include][:actions].include?(:show), "SHOULD contain :show"

    assert obj.current_filter[:include][:controllers].kind_of?(Array), ":controllers SHOULD be an array"
    assert obj.current_filter[:include][:controllers].blank?, "SHOULD be an empty array"

    assert obj.current_filter[:include][:names].kind_of?(Array), ":names SHOULD be an array"
    assert obj.current_filter[:include][:names].blank?, "SHOULD be an empty array"

    assert obj.current_filter[:include][:verbs].kind_of?(Array), ":verbs SHOULD be an array"
    assert obj.current_filter[:include][:verbs].blank?, "SHOULD be an empty array"

  end

  test "verify copy filter creates a separate Hash object" do

    obj = DuckMap::FilterStack.new
    source = DuckMap::FilterStack::DEFAULT_FILTER
    copy = obj.copy_filter(source)

    assert source.kind_of?(Hash)
    assert source[:exclude].kind_of?(Hash)
    assert source[:include].kind_of?(Hash)

    assert copy.kind_of?(Hash)
    assert copy[:exclude].kind_of?(Hash)
    assert copy[:include].kind_of?(Hash)

    # verify the :exclude
    assert source[:exclude][:verbs].include?(:delete)
    assert source[:exclude][:verbs].include?(:post)
    assert source[:exclude][:verbs].include?(:put)
    assert !source[:exclude][:verbs].include?(:get)

    assert copy[:exclude][:verbs].include?(:delete)
    assert copy[:exclude][:verbs].include?(:post)
    assert copy[:exclude][:verbs].include?(:put)
    assert !copy[:exclude][:verbs].include?(:get)

    copy[:exclude][:verbs].delete(:post)
    copy[:exclude][:verbs].push(:get)

    assert source[:exclude][:verbs].include?(:delete)
    assert source[:exclude][:verbs].include?(:post)
    assert source[:exclude][:verbs].include?(:put)
    assert !source[:exclude][:verbs].include?(:get)

    assert copy[:exclude][:verbs].include?(:delete)
    assert !copy[:exclude][:verbs].include?(:post)
    assert copy[:exclude][:verbs].include?(:put)
    assert copy[:exclude][:verbs].include?(:get)

    # verify the :include
    assert source[:include][:actions].include?(:index)
    assert source[:include][:actions].include?(:show)
    assert !source[:include][:actions].include?(:new)

    assert copy[:include][:actions].include?(:index)
    assert copy[:include][:actions].include?(:show)
    assert !copy[:include][:actions].include?(:new)

    copy[:include][:actions].delete(:index)
    copy[:include][:actions].push(:new)

    assert source[:include][:actions].include?(:index)
    assert source[:include][:actions].include?(:show)
    assert !source[:include][:actions].include?(:new)

    assert copy[:include][:actions].include?(:show)
    assert !copy[:include][:actions].include?(:index)
    assert copy[:include][:actions].include?(:new)

  end

  test "include filter to actions" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.include_filter(:actions, :index)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.include_filter(:actions, :show)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.include_filter(:actions, [:index, :show])
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.include_filter(:actions, :index, :show)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.include_filter(:actions, :new)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 3

    obj.include_filter(:actions, :edit)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 4

    obj.include_filter(:actions, ["update", :destroy])
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 6

    obj.include_filter(:actions, :update)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 6

  end

  test "exclude filter from actions" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.exclude_filter(:actions, :index)
    assert obj.current_filter[:exclude][:actions].length == 1
    assert obj.current_filter[:include][:actions].length == 1

    obj.exclude_filter(:actions, :show)
    assert obj.current_filter[:exclude][:actions].length == 2
    assert obj.current_filter[:include][:actions].length == 0

    obj.reset
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 2

    obj.exclude_filter(:actions, [:index, :show])
    assert obj.current_filter[:exclude][:actions].length == 2
    assert obj.current_filter[:include][:actions].length == 0

    obj.exclude_filter(:actions, :edit)
    assert obj.current_filter[:exclude][:actions].length == 3
    assert obj.current_filter[:include][:actions].length == 0

    obj.exclude_filter(:actions, ["update", :destroy])
    assert obj.current_filter[:exclude][:actions].length == 5
    assert obj.current_filter[:include][:actions].length == 0

  end

  test "clear_filters" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:exclude][:controllers].length == 0
    assert obj.current_filter[:exclude][:names].length == 0
    assert obj.current_filter[:exclude][:verbs].length == 3

    assert obj.current_filter[:include][:actions].length == 2
    assert obj.current_filter[:include][:controllers].length == 0
    assert obj.current_filter[:include][:names].length == 0
    assert obj.current_filter[:include][:verbs].length == 0

    obj.clear_filters
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:exclude][:controllers].length == 0
    assert obj.current_filter[:exclude][:names].length == 0
    assert obj.current_filter[:exclude][:verbs].length == 0

    assert obj.current_filter[:include][:actions].length == 0
    assert obj.current_filter[:include][:controllers].length == 0
    assert obj.current_filter[:include][:names].length == 0
    assert obj.current_filter[:include][:verbs].length == 0

  end

  test "push a filter onto the end of the stack" do
    obj = DuckMap::FilterStack.new
    obj.include_filter(:actions, :update)
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 3

    obj.push
    assert obj.current_filter[:exclude][:actions].length == 0
    assert obj.current_filter[:include][:actions].length == 3

    obj.exclude_filter(:actions, :update)
    assert obj.current_filter[:exclude][:actions].length == 1
    assert obj.current_filter[:include][:actions].length == 2
    assert obj.stack.first[:exclude][:actions].length == 0
    assert obj.stack.first[:include][:actions].length == 3

  end

  test "pop a filter from the end of the stack" do
    obj = DuckMap::FilterStack.new

    obj.push
    assert obj.stack.length == 2

    obj.push
    assert obj.stack.length == 3

    obj.pop
    assert obj.stack.length == 2

    # should never allow an empty array
    obj.pop
    assert obj.stack.length == 1

    obj.pop
    assert obj.stack.length == 1

    obj.pop
    assert obj.stack.length == 1

  end

  test "clear_filter(key)" do

    obj = DuckMap::FilterStack.new

    obj.exclude_filter(:actions, :update)
    assert obj.current_filter[:exclude][:actions].length == 1
    assert obj.current_filter[:exclude][:verbs].length == 3
    assert obj.current_filter[:include][:actions].length == 2
    assert obj.current_filter[:include][:verbs].length == 0

    obj.clear_filter(:exclude, :verbs)
    assert obj.current_filter[:exclude][:actions].length == 1
    assert obj.current_filter[:exclude][:verbs].length == 0
    assert obj.current_filter[:include][:actions].length == 2
    assert obj.current_filter[:include][:verbs].length == 0

  end

end




