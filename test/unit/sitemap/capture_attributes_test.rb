require 'test_helper'

class CaptureAttributesTest < ActiveSupport::TestCase

  ##################################################################################
  test "test argument logic to sitemap_capture_attributes" do

    class TestObject11 < ApplicationController
      acts_as_sitemap title: :my_title,
                      keywords: :tags,
                      description: :content,
                      lastmod: :last_updated_at

      attr_accessor :my_title
      attr_accessor :tags
      attr_accessor :content
      attr_accessor :last_updated_at
    end

    object = TestObject11.new
    object.my_title = "my title"
    object.tags = "this that other"
    object.content = "this is a test"
    object.last_updated_at = Time.now

    attributes = {title: :my_title,
                  keywords: nil,
                  description: "this is my desc",
                  lastmod: :invalid_method_name}

    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert !values.has_key?(:keywords)
    assert values[:description].eql?("this is my desc")
    assert !values.has_key?(:lastmod)
    assert !values.has_key?(:invalid_method_name)

  end

  ##################################################################################
  test "target object without attributes should yield empty Hash" do
    # this test works completely on defaults
    # controller object does not have any of the attributes, so,
    # it should always return an empty Hash

    class TestObject01 < ApplicationController
    end

    object = TestObject01.new

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert values.blank?
  end

  ##################################################################################
  test "target object with all attributes should return all values" do

    class TestObject02 < ApplicationController
      attr_accessor :title
      attr_accessor :keywords
      attr_accessor :description
      attr_accessor :updated_at
    end

    object = TestObject02.new
    object.title = "my title"
    object.keywords = "this that other"
    object.description = "this is a test"
    object.updated_at = Time.now

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].kind_of?(Time)
  end

  ##################################################################################
  test "should map attributes to target object" do

    class TestObject03 < ApplicationController
      acts_as_sitemap title: :my_title,
                      keywords: :tags,
                      description: :content,
                      lastmod: :last_updated_at

      attr_accessor :my_title
      attr_accessor :tags
      attr_accessor :content
      attr_accessor :last_updated_at
    end

    object = TestObject03.new
    object.my_title = "my title"
    object.tags = "this that other"
    object.content = "this is a test"
    object.last_updated_at = Time.now

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].kind_of?(Time)
  end

  ##################################################################################
  test "setting attribute to nil should prevent it from capture" do

    class TestObject04 < ApplicationController
      acts_as_sitemap title: nil,
                      keywords: :tags,
                      description: :content,
                      lastmod: :last_updated_at

      attr_accessor :my_title
      attr_accessor :tags
      attr_accessor :content
      attr_accessor :last_updated_at
    end

    object = TestObject04.new
    object.my_title = "my title"
    object.tags = "this that other"
    object.content = "this is a test"
    object.last_updated_at = Time.now

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].blank?
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].kind_of?(Time)
  end

  ##################################################################################
  test "setting attribute to string should use the string during capture" do

    class TestObject05 < ApplicationController
      acts_as_sitemap title: "five controller",     # setting as string here
                      keywords: "bike car truck",   # setting as string here
                      description: :content,
                      lastmod: :last_updated_at

      attr_accessor :my_title
      attr_accessor :tags
      attr_accessor :content
      attr_accessor :last_updated_at
    end

    object = TestObject05.new
    object.my_title = "my title"
    object.tags = "this that other"
    object.content = "this is a test"
    object.last_updated_at = Time.now

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("five controller")       # verifying it here
    assert values[:keywords].eql?("bike car truck")     # verifying it here
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].kind_of?(Time)
  end

  ##################################################################################
  test "target object without attributes should use default values" do

    class TestObject06 < ApplicationController
    end

    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      title "my title"
      keywords "this that and the other"
      description "moe, larry the cheese..."
      lastmod "12/10/2012"
    end

    values = DuckMap::Config.copy_attributes

    object = TestObject06.new

    attributes = object.sitemap_stripped_attributes("default")
    values.merge!(object.sitemap_capture_attributes(attributes))

    assert values.kind_of?(Hash)
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that and the other")
    assert values[:description].eql?("moe, larry the cheese...")
    assert values[:lastmod].eql?(Time.new(2012, 12, 10, 0, 0, 0))
  end

  ##################################################################################
  test "target object with all attributes should merge with default values" do

    class TestObject07 < ApplicationController
      attr_accessor :title
      attr_accessor :keywords
      attr_accessor :description
      attr_accessor :updated_at
    end

    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      title "my title"
      keywords "this that and the other"
      description "moe, larry the cheese..."
      lastmod "12/10/2012"
    end

    object = TestObject07.new
    object.title = "my title"
    object.keywords = "this that other"
    object.description = "this is a test"
    object.updated_at = Time.now

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].kind_of?(Time)
  end

  ##################################################################################
  test "setting default acts_as_sitemap should be used by target object" do

    class TestObject08 < ApplicationController
      attr_accessor :my_title
      attr_accessor :my_keywords
      attr_accessor :my_description
      attr_accessor :my_updated_at
    end

    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      title "my title"
      keywords "this that and the other"
      description "moe, larry the cheese..."
      lastmod "12/10/2012"

      acts_as_sitemap title: :my_title,
                      keywords: :my_keywords,
                      description: :my_description,
                      lastmod: :my_updated_at
    end

    object = TestObject08.new
    object.my_title = "my title"
    object.my_keywords = "this that other"
    object.my_description = "this is a test"
    object.my_updated_at = Time.now

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].kind_of?(Time)
  end

  ##################################################################################
  test "target object should use multiple attributes for multiple actions" do

    class TestObject09 < ApplicationController
      acts_as_sitemap title: :my_title_01,
                      keywords: :my_keywords_01,
                      description: :my_description_01,
                      lastmod: :my_updated_at_01

      acts_as_sitemap :index, title: :my_title_02,
                              keywords: :my_keywords_02,
                              description: :my_description_02,
                              lastmod: :my_updated_at_02

      attr_accessor :my_title_01
      attr_accessor :my_keywords_01
      attr_accessor :my_description_01
      attr_accessor :my_updated_at_01

      attr_accessor :my_title_02
      attr_accessor :my_keywords_02
      attr_accessor :my_description_02
      attr_accessor :my_updated_at_02
    end

    object = TestObject09.new
    object.my_title_01 = "my title"
    object.my_keywords_01 = "this that other"
    object.my_description_01 = "this is a test"
    object.my_updated_at_01 = Time.new(2012, 12, 10, 0, 0, 0)

    object.my_title_02 = "my title 02"
    object.my_keywords_02 = "this that other thing"
    object.my_description_02 = "this is a test again"
    object.my_updated_at_02 = Time.new(2012, 12, 20, 0, 0, 0)

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].eql?(Time.new(2012, 12, 10, 0, 0, 0))

    attributes = object.sitemap_stripped_attributes("index")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title 02")
    assert values[:keywords].eql?("this that other thing")
    assert values[:description].eql?("this is a test again")
    assert values[:lastmod].eql?(Time.new(2012, 12, 20, 0, 0, 0))
  end

  ##################################################################################
  test "target object should use multiple attributes for multiple actions defined via config" do

    class TestObject10 < ApplicationController
      attr_accessor :my_title_01
      attr_accessor :my_keywords_01
      attr_accessor :my_description_01
      attr_accessor :my_updated_at_01

      attr_accessor :my_title_02
      attr_accessor :my_keywords_02
      attr_accessor :my_description_02
      attr_accessor :my_updated_at_02
    end

    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      title "my title"
      keywords "this that and the other"
      description "moe, larry the cheese..."
      lastmod "12/10/2012"

      acts_as_sitemap title: :my_title_01,
                      keywords: :my_keywords_01,
                      description: :my_description_01,
                      lastmod: :my_updated_at_01

      acts_as_sitemap :index, title: :my_title_02,
                              keywords: :my_keywords_02,
                              description: :my_description_02,
                              lastmod: :my_updated_at_02
    end

    object = TestObject10.new
    object.my_title_01 = "my title"
    object.my_keywords_01 = "this that other"
    object.my_description_01 = "this is a test"
    object.my_updated_at_01 = Time.new(2012, 12, 10, 0, 0, 0)

    object.my_title_02 = "my title 02"
    object.my_keywords_02 = "this that other thing"
    object.my_description_02 = "this is a test again"
    object.my_updated_at_02 = Time.new(2012, 12, 20, 0, 0, 0)

    attributes = object.sitemap_stripped_attributes("default")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title")
    assert values[:keywords].eql?("this that other")
    assert values[:description].eql?("this is a test")
    assert values[:lastmod].eql?(Time.new(2012, 12, 10, 0, 0, 0))

    attributes = object.sitemap_stripped_attributes("index")
    values = object.sitemap_capture_attributes(attributes)

    assert values.kind_of?(Hash)
    assert !values.blank?
    assert values[:title].eql?("my title 02")
    assert values[:keywords].eql?("this that other thing")
    assert values[:description].eql?("this is a test again")
    assert values[:lastmod].eql?(Time.new(2012, 12, 20, 0, 0, 0))
  end

end













