require 'test_helper'

class FilterStackTest < ActiveSupport::TestCase

  test "default filter stack" do

    obj = DuckMap::FilterStack.new

    assert obj.stack.kind_of?(Array), "obj.stack SHOULD BE an array and is NOT"
    assert obj.stack.length > 0, "obj.stack SHOULD have at least one item"
    assert obj.stack.last.kind_of?(Hash), "obj.stack.last item SHOULD BE a Hash"

    assert obj.stack.last[:actions].kind_of?(Array), "obj.stack.last item SHOULD contain :actions array"
    assert obj.stack.last[:actions].include?(:index), "obj.stack.last[:actions] SHOULD contain :index item"
    assert obj.stack.last[:actions].include?(:show), "obj.stack.last[:actions] SHOULD contain :show item"

    assert obj.stack.last[:verbs].kind_of?(Array), "obj.stack.last item SHOULD contain :verbs array"
    assert obj.stack.last[:verbs].blank?, "obj.stack.last[:verbs] SHOULD BE blank"

    assert obj.stack.last[:names].kind_of?(Array), "obj.stack.last item SHOULD contain :names array"
    assert obj.stack.last[:names].blank?, "obj.stack.last[:names] SHOULD BE blank"

    assert obj.stack.last[:controllers].kind_of?(Array), "obj.stack.last item SHOULD contain :controllers array"
    assert obj.stack.last[:controllers].blank?, "obj.stack.last[:controllers] SHOULD BE blank"

  end

  test "verify copy filter creates a separate Hash object" do

    obj = DuckMap::FilterStack.new
    source = DuckMap::FilterStack::DEFAULT_FILTER
    copy = obj.copy_filter(source)

    assert source.kind_of?(Hash)
    assert copy.kind_of?(Hash)

    assert source[:actions].include?(:index)
    assert source[:actions].include?(:show)
    assert !source[:actions].include?(:new)

    assert copy[:actions].include?(:index)
    assert copy[:actions].include?(:show)
    assert !copy[:actions].include?(:new)

    copy[:actions].delete(:index)
    copy[:actions].push(:new)

    assert source[:actions].include?(:index)
    assert source[:actions].include?(:show)
    assert !source[:actions].include?(:new)

    assert !copy[:actions].include?(:index)
    assert copy[:actions].include?(:show)
    assert copy[:actions].include?(:new)

  end

  test "include filter to actions" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:actions].length == 2
    assert obj.current_filter[:verbs].length == 0

    obj.include_filter(:actions, :index)
    assert obj.current_filter[:actions].length == 2

    obj.include_filter(:actions, :show)
    assert obj.current_filter[:actions].length == 2

    obj.include_filter(:actions, [:index, :show])
    assert obj.current_filter[:actions].length == 2

    obj.include_filter(:actions, :new)
    assert obj.current_filter[:actions].length == 3

    obj.include_filter(:actions, :edit)
    assert obj.current_filter[:actions].length == 4

    obj.include_filter(:actions, ["update", :destroy])
    assert obj.current_filter[:actions].length == 6

    obj.include_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 6

  end

  test "exclude filter from actions" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:actions].length == 2
    assert obj.current_filter[:verbs].length == 0

    obj.exclude_filter(:actions, :index)
    assert obj.current_filter[:actions].length == 1

    obj.exclude_filter(:actions, :show)
    assert obj.current_filter[:actions].length == 0

    obj.reset
    obj.exclude_filter(:actions, [:index, :show])
    assert obj.current_filter[:actions].length == 0

    obj.reset
    obj.exclude_filter(:actions, :new)
    assert obj.current_filter[:actions].length == 2

    obj.exclude_filter(:actions, :edit)
    assert obj.current_filter[:actions].length == 2

    obj.exclude_filter(:actions, ["update", :destroy])
    assert obj.current_filter[:actions].length == 2

    obj.exclude_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 2

    obj.include_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 3

    obj.exclude_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 2

  end

  test "clear_filters" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:actions].length == 2
    assert obj.current_filter[:verbs].length == 0

    obj.clear_filters
    assert obj.current_filter[:actions].length == 0
    assert obj.current_filter[:verbs].length == 0
    assert obj.current_filter[:names].length == 0
    assert obj.current_filter[:controllers].length == 0

  end

  test "push a filter onto the end of the stack" do
    obj = DuckMap::FilterStack.new
    obj.include_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 3

    obj.push
    assert obj.current_filter[:actions].length == 3

    obj.exclude_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 2
    assert obj.stack.first[:actions].length == 3

  end

  test "pop a filter from the end of the stack" do
    obj = DuckMap::FilterStack.new
    obj.include_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 3

    obj.push
    assert obj.current_filter[:actions].length == 3

    obj.exclude_filter(:actions, :update)
    assert obj.current_filter[:actions].length == 2
    assert obj.stack.first[:actions].length == 3

    obj.pop
    assert obj.current_filter[:actions].length == 3

  end

  test "clear_filter(key)" do

    obj = DuckMap::FilterStack.new

    assert obj.current_filter[:actions].length == 2
    assert obj.current_filter[:verbs].length == 0

    obj.clear_filter(:actions)
    assert obj.current_filter[:actions].length == 0
    assert obj.current_filter[:verbs].length == 0
    assert obj.current_filter[:names].length == 0
    assert obj.current_filter[:controllers].length == 0

  end

end




