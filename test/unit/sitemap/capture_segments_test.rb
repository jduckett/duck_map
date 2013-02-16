require 'test_helper'

class CaptureSegmentsTest < ActiveSupport::TestCase

  ##################################################################################
  test "target object without attributes should yield empty Hash" do
    # this test works completely on defaults
    # controller object does not have any of the attributes, so,
    # it should always return an empty Hash

    class TestObject01 < ApplicationController
    end

    object = TestObject01.new

    attributes = object.sitemap_attributes("default")[:segments]
    values = object.sitemap_capture_segments(attributes, [])

    assert values.kind_of?(Hash)
    assert values.blank?
  end

  ##################################################################################
  test "target object with attributes should return populated hash" do

    class TestObject02 < ApplicationController
      attr_accessor :id
    end

    object = TestObject02.new
    object.id = 1

    attributes = object.sitemap_attributes("default")[:segments]
    values = object.sitemap_capture_segments(attributes, [:id])

    assert values.kind_of?(Hash)
    assert values[:id].eql?(1)
  end

  ##################################################################################
  test "target object should return mapped attributes hash" do

    class TestObject03 < ApplicationController
      sitemap_segments id: :my_id
      attr_accessor :id
      attr_accessor :my_id
    end

    object = TestObject03.new
    object.id = 1
    object.my_id = 2

    attributes = object.sitemap_attributes("default")[:segments]
    values = object.sitemap_capture_segments(attributes, [:id])

    assert values.kind_of?(Hash)
    assert values[:id].eql?(2)
  end

  ##################################################################################
  test "can pass empty or nil attributes" do

    class TestObject04 < ApplicationController
      attr_accessor :id
    end

    object = TestObject04.new
    object.id = 1

    values = object.sitemap_capture_segments(nil, [:id])

    assert values.kind_of?(Hash)
    assert values[:id].eql?(1)
  end

  ##################################################################################
  test "can pass empty or nil segment keys" do

    class TestObject05 < ApplicationController
    end

    object = TestObject05.new

    values = object.sitemap_capture_segments(nil, nil)

    assert values.kind_of?(Hash)
    assert values.blank?
  end

  ##################################################################################
  test "can pass no arguments" do

    class TestObject06 < ApplicationController
    end

    object = TestObject06.new

    values = object.sitemap_capture_segments

    assert values.kind_of?(Hash)
    assert values.blank?
  end

end













