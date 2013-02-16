require 'test_helper'

class ArrayHelperObject
  include DuckMap::ArrayHelper

end

class ArrayHelperTest < ActiveSupport::TestCase

  test "convert Symbols to Strings" do
    obj = ArrayHelperObject.new
    assert obj.respond_to?(:convert_to)

    values = [:new_book, :edit_book, :create_book, :destroy_book]
    new_values = obj.convert_to(values, :string)

    assert new_values.kind_of?(Array)
    assert new_values.length == values.length

    new_values.each do |value|
      assert value.kind_of?(String)
    end

  end

  test "convert Symbols to Symbols" do
    obj = ArrayHelperObject.new
    assert obj.respond_to?(:convert_to)

    values = [:new_book, :edit_book, :create_book, :destroy_book]
    new_values = obj.convert_to(values, :symbol)

    assert new_values.kind_of?(Array)
    assert new_values.length == values.length

    new_values.each do |value|
      assert value.kind_of?(Symbol)
    end

  end

  test "convert Strings to Symbols" do
    obj = ArrayHelperObject.new
    assert obj.respond_to?(:convert_to)

    values = ["new_book", "edit_book", "create_book", "destroy_book"]
    new_values = obj.convert_to(values, :symbol)

    assert new_values.kind_of?(Array)
    assert new_values.length == values.length

    new_values.each do |value|
      assert value.kind_of?(Symbol)
    end

  end

  test "convert Strings to Strings" do
    obj = ArrayHelperObject.new
    assert obj.respond_to?(:convert_to)

    values = ["new_book", "edit_book", "create_book", "destroy_book"]
    new_values = obj.convert_to(values, :string)

    assert new_values.kind_of?(Array)
    assert new_values.length == values.length

    new_values.each do |value|
      assert value.kind_of?(String)
    end

  end

end
