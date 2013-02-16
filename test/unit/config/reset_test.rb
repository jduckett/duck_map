require 'test_helper'

class ResetTest < ActiveSupport::TestCase

  ##################################################################################
  test "DuckMap::Config.sitemap_attributes_hash should NEVER return nil" do

    # even after directly setting sitemap_attributes_hash to nil, it should
    # NEVER return nil
    DuckMap::Config.sitemap_attributes_hash = nil
    assert DuckMap::Config.sitemap_attributes_hash.kind_of?(Hash)
  end

  ##################################################################################
  test "DuckMap::Config.sitemap_attributes_hash should NEVER return nil using reset" do

    DuckMap::Config.reset
    assert DuckMap::Config.sitemap_attributes_hash.kind_of?(Hash)
  end

  ##################################################################################
  test "DuckMap::Config.reset(:sitemap_attributes_hash) should leave other values in tact" do

    assert !DuckMap::Config.sitemap_attributes_defined.kind_of?(NilClass)

    # go ahead and reset everything
    DuckMap::Config.reset

    # confirm default values
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?(:title)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?(:title)
    assert DuckMap::Config.title.eql?("Untitled")
    assert DuckMap::Config.sitemap_attributes_defined.kind_of?(FalseClass)

    # set and confirm new values
    DuckMap::Config.title = "my title"
    assert DuckMap::Config.title.eql?("my title")

    DuckMap::Config.sitemap_attributes_defined = true
    assert DuckMap::Config.sitemap_attributes_defined.kind_of?(TrueClass)

    DuckMap::Config.sitemap_attributes_hash[:default][:title] = "default title"
    DuckMap::Config.sitemap_attributes_hash[:index][:title] = "index title"

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?("default title")
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?("index title")

    # reset sitemap_attributes_hash ONLY and leave others in tact
    DuckMap::Config.reset(:sitemap_attributes_hash)

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?(:title)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?(:title)

    assert DuckMap::Config.title.eql?("my title")
    assert DuckMap::Config.sitemap_attributes_defined.kind_of?(TrueClass)

  end

  ##################################################################################
  test "DuckMap::Config.reset(:attributes) should leave other values in tact" do

    assert !DuckMap::Config.sitemap_attributes_defined.kind_of?(NilClass)

    # go ahead and reset everything
    DuckMap::Config.reset

    # confirm default values
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?(:title)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?(:title)
    assert DuckMap::Config.title.eql?("Untitled")
    assert DuckMap::Config.keywords.kind_of?(NilClass)
    assert DuckMap::Config.sitemap_attributes_defined.kind_of?(FalseClass)

    # set and confirm new values
    DuckMap::Config.title = "my title"
    assert DuckMap::Config.title.eql?("my title")

    DuckMap::Config.keywords = "moe larry the cheese"
    assert DuckMap::Config.keywords.eql?("moe larry the cheese")

    DuckMap::Config.sitemap_attributes_defined = true
    assert DuckMap::Config.sitemap_attributes_defined.kind_of?(TrueClass)

    DuckMap::Config.sitemap_attributes_hash[:default][:title] = "default title"
    DuckMap::Config.sitemap_attributes_hash[:index][:title] = "index title"

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?("default title")
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?("index title")

    # reset sitemap_attributes_hash ONLY and leave others in tact
    DuckMap::Config.reset(:attributes)

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?("default title")
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?("index title")

    assert DuckMap::Config.title.eql?("Untitled")
    assert DuckMap::Config.keywords.kind_of?(NilClass)
    assert DuckMap::Config.sitemap_attributes_defined.kind_of?(TrueClass)

  end

  ##################################################################################
  test "DuckMap::Config.reset should not affect object instances" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    # define a couple of objects
    class ResetObject01
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    class ResetObject02
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # class method should always return nil until instantiated
    # by an instance of the object
    assert ResetObject01.sitemap_attributes_hash.kind_of?(NilClass)
    assert ResetObject02.sitemap_attributes_hash.kind_of?(NilClass)

    # create two separate objects
    a = ResetObject01.new
    b = ResetObject02.new

    # instantiate attributes on both objects
    assert a.sitemap_attributes.kind_of?(Hash)
    assert b.sitemap_attributes.kind_of?(Hash)

    # set some values
    a.sitemap_attributes(:default)[:title] = "default title"
    b.sitemap_attributes(:default)[:title] = "default title"
    assert a.sitemap_attributes(:default)[:title].eql?("default title")
    assert b.sitemap_attributes(:default)[:title].eql?("default title")

    # reset config
    DuckMap::Config.reset

    # confirm object instances have not been affected
    assert a.sitemap_attributes(:default)[:title].eql?("default title")
    assert b.sitemap_attributes(:default)[:title].eql?("default title")

  end

end
