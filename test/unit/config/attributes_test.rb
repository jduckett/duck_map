require 'test_helper'

class AttributesTest < ActiveSupport::TestCase

  ##################################################################################
  test "default value for class.sitemap_attributes_hash on should be nil" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class AttributesObject01
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # verify class.sitemap_attributes_hash is nil
    assert AttributesObject01.sitemap_attributes_hash.nil?

    # create an object and verify again
    a = AttributesObject01.new
    assert a.class.sitemap_attributes_hash.nil?
    assert a.sitemap_attributes_hash.nil?

    # now, instantiate and verify nothing is nil
    assert a.sitemap_attributes.kind_of?(Hash)
    assert a.class.sitemap_attributes_hash.kind_of?(Hash)
    assert a.sitemap_attributes_hash.kind_of?(Hash)

  end

  ##################################################################################
  test "default value for object.sitemap_attributes should always be a hash" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class AttributesObject02
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # create an object
    a = AttributesObject02.new

    # verify sitemap_attributes is a hash
    assert a.sitemap_attributes.kind_of?(Hash)

  end

  ##################################################################################
  test "default value for object.sitemap_attributes without key should always return hash for :default" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class AttributesObject03
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # create an object
    a = AttributesObject03.new

    # make sure values have been loaded first
    assert a.sitemap_attributes.kind_of?(Hash)

    # change some values directly on the hash
    a.class.sitemap_attributes_hash[:default][:title] = :default_title
    a.class.sitemap_attributes_hash[:index][:title] = :index_title

    # verify accessing without a key will return :default
    assert a.sitemap_attributes[:title].eql?(:default_title)
    assert a.sitemap_attributes(:index)[:title].eql?(:index_title)

  end

  ##################################################################################
  test "class.is_sitemap_attributes_defined? default should be false" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class AttributesObject04
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # verify is false
    assert !AttributesObject04.is_sitemap_attributes_defined?

  end

  ##################################################################################
  test "object.is_sitemap_attributes_defined? default should be false" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class AttributesObject05
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # create an object
    a = AttributesObject05.new

    # verify is false
    assert !a.class.is_sitemap_attributes_defined?
    assert !a.is_sitemap_attributes_defined?

  end

  ##################################################################################
  test "stripped attributes should never contain Hashes" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class AttributesObject06
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    a = AttributesObject06.new

    attributes = a.sitemap_stripped_attributes("index")

    assert !attributes.has_key?(:handler)
    assert !attributes.has_key?(:segments)

    attributes.each do |value|
      assert value.kind_of?(Array)
      assert !value.last.kind_of?(Hash)
    end

  end

end











