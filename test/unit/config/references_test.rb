require 'test_helper'

class ReferencesTest < ActiveSupport::TestCase

  ##################################################################################
  test "changing value on DuckMap::Config should not affect object instances" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class ReferenceObject01
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    class ReferenceObject02
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # create an instance
    a = ReferenceObject01.new

    # instantiate one instance on one object only
    assert a.sitemap_attributes.kind_of?(Hash)

    # confirm all references (class and instance) to sitemap_attributes_hash are a Hash
    assert ReferenceObject01.sitemap_attributes_hash.kind_of?(Hash)
    assert a.class.sitemap_attributes_hash.kind_of?(Hash)

    # change some values and verify the change
    a.sitemap_attributes(:default)[:title] = "default title"
    a.sitemap_attributes(:index)[:title] = "index title"

    assert a.sitemap_attributes(:default)[:title].eql?("default title")
    assert a.sitemap_attributes(:index)[:title].eql?("index title")

    # Now, change some values on DuckMap::Config.sitemap_attributes_hash
    DuckMap::Config.sitemap_attributes_hash[:default][:title] = "new default title"
    DuckMap::Config.sitemap_attributes_hash[:index][:title] = "new index title"

    # confirm value has changed
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?("new default title")
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?("new index title")

    # confirm value has NOT changed
    assert a.sitemap_attributes(:default)[:title].eql?("default title")
    assert a.sitemap_attributes(:index)[:title].eql?("index title")

    # create another type of object
    b = ReferenceObject02.new

    # confirm new object picked up the changes
    assert b.sitemap_attributes(:default)[:title].eql?("new default title")
    assert b.sitemap_attributes(:index)[:title].eql?("new index title")

    # re-confirm value has NOT changed
    assert a.sitemap_attributes(:default)[:title].eql?("default title")
    assert a.sitemap_attributes(:index)[:title].eql?("index title")

  end

  ##################################################################################
  test "changing value on one class should not affect values of another class" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class ReferenceObject03
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    class ReferenceObject04
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # create an instance
    a = ReferenceObject03.new
    b = ReferenceObject04.new

    # make sure the attributes have been initialized
    assert a.sitemap_attributes.kind_of?(Hash)
    assert b.sitemap_attributes.kind_of?(Hash)

    # verify some default values
    assert a.sitemap_attributes(:default)[:title].eql?(:title)
    assert a.sitemap_attributes(:default)[:keywords].eql?(:keywords)
    assert a.sitemap_attributes(:index)[:title].eql?(:title)
    assert a.sitemap_attributes(:index)[:keywords].eql?(:keywords)

    assert b.sitemap_attributes(:default)[:title].eql?(:title)
    assert b.sitemap_attributes(:default)[:keywords].eql?(:keywords)
    assert b.sitemap_attributes(:index)[:title].eql?(:title)
    assert b.sitemap_attributes(:index)[:keywords].eql?(:keywords)

    # change some values on both objects
    a.sitemap_attributes(:default)[:title] = :a_default_title
    a.sitemap_attributes(:index)[:keywords] = :a_index_keywords

    b.sitemap_attributes(:default)[:keywords] = :b_default_keywords
    b.sitemap_attributes(:index)[:title] = :b_index_title

    assert a.sitemap_attributes(:default)[:title].eql?(:a_default_title)
    assert a.sitemap_attributes(:default)[:keywords].eql?(:keywords)
    assert a.sitemap_attributes(:index)[:title].eql?(:title)
    assert a.sitemap_attributes(:index)[:keywords].eql?(:a_index_keywords)

    assert b.sitemap_attributes(:default)[:title].eql?(:title)
    assert b.sitemap_attributes(:default)[:keywords].eql?(:b_default_keywords)
    assert b.sitemap_attributes(:index)[:title].eql?(:b_index_title)
    assert b.sitemap_attributes(:index)[:keywords].eql?(:keywords)

  end

  ##################################################################################
  test "changing value on one class should affect all instances of that class" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class ReferenceObject05
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    class ReferenceObject06
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # create an instance
    a = ReferenceObject05.new
    b = ReferenceObject05.new
    c = ReferenceObject05.new
    d = ReferenceObject06.new
    e = ReferenceObject06.new
    f = ReferenceObject06.new

    # make sure the attributes have been initialized
    assert a.sitemap_attributes.kind_of?(Hash)
    assert b.sitemap_attributes.kind_of?(Hash)
    assert c.sitemap_attributes.kind_of?(Hash)
    assert d.sitemap_attributes.kind_of?(Hash)
    assert e.sitemap_attributes.kind_of?(Hash)
    assert f.sitemap_attributes.kind_of?(Hash)

    # change value on class and verify all instances reflect the change
    ReferenceObject05.sitemap_attributes[:default][:title] = :title_05
    assert a.sitemap_attributes(:default)[:title].eql?(:title_05)
    assert b.sitemap_attributes(:default)[:title].eql?(:title_05)
    assert c.sitemap_attributes(:default)[:title].eql?(:title_05)

    assert ReferenceObject06.sitemap_attributes[:default][:title].eql?(:title)
    assert d.sitemap_attributes(:default)[:title].eql?(:title)
    assert e.sitemap_attributes(:default)[:title].eql?(:title)
    assert f.sitemap_attributes(:default)[:title].eql?(:title)

    ReferenceObject06.sitemap_attributes[:default][:title] = :title_06

    assert ReferenceObject05.sitemap_attributes[:default][:title].eql?(:title_05)
    assert a.sitemap_attributes(:default)[:title].eql?(:title_05)
    assert b.sitemap_attributes(:default)[:title].eql?(:title_05)
    assert c.sitemap_attributes(:default)[:title].eql?(:title_05)
    assert d.sitemap_attributes(:default)[:title].eql?(:title_06)
    assert e.sitemap_attributes(:default)[:title].eql?(:title_06)
    assert f.sitemap_attributes(:default)[:title].eql?(:title_06)

    # change value on an object verify all instances and the class reflect the change
    a.sitemap_attributes(:default)[:title] = :title_a
    assert ReferenceObject05.sitemap_attributes[:default][:title].eql?(:title_a)
    assert b.sitemap_attributes(:default)[:title].eql?(:title_a)
    assert c.sitemap_attributes(:default)[:title].eql?(:title_a)

    assert ReferenceObject06.sitemap_attributes[:default][:title].eql?(:title_06)
    assert d.sitemap_attributes(:default)[:title].eql?(:title_06)
    assert e.sitemap_attributes(:default)[:title].eql?(:title_06)
    assert f.sitemap_attributes(:default)[:title].eql?(:title_06)

    d.sitemap_attributes(:default)[:title] = :title_d
    assert ReferenceObject06.sitemap_attributes[:default][:title].eql?(:title_d)
    assert e.sitemap_attributes(:default)[:title].eql?(:title_d)
    assert f.sitemap_attributes(:default)[:title].eql?(:title_d)

    assert ReferenceObject05.sitemap_attributes[:default][:title].eql?(:title_a)
    assert a.sitemap_attributes(:default)[:title].eql?(:title_a)
    assert b.sitemap_attributes(:default)[:title].eql?(:title_a)
    assert c.sitemap_attributes(:default)[:title].eql?(:title_a)

  end

  ##################################################################################
  test "confirm class.sitemap_attributes_hash nil until object.sitemap_attributes creates it" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    # define a couple of objects
    class ReferenceObject07
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    class ReferenceObject08
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
    end

    # reset again just to satisfy being anal
    DuckMap::Config.reset

    # class method should always return nil until instantiated
    # by an instance of the object
    assert ReferenceObject07.sitemap_attributes_hash.kind_of?(NilClass)
    assert ReferenceObject08.sitemap_attributes_hash.kind_of?(NilClass)

    # create two separate objects
    a = ReferenceObject07.new
    b = ReferenceObject08.new

    # confirm all references (class and instance) to sitemap_attributes_hash are nil
    assert ReferenceObject07.sitemap_attributes_hash.kind_of?(NilClass)
    assert ReferenceObject08.sitemap_attributes_hash.kind_of?(NilClass)
    assert a.sitemap_attributes_hash.kind_of?(NilClass)
    assert b.sitemap_attributes_hash.kind_of?(NilClass)

    # instantiate one instance on one object only
    assert a.sitemap_attributes.kind_of?(Hash)

    # this should always be a hash
    assert ReferenceObject07.sitemap_attributes_hash.kind_of?(Hash)

    # these should remain nil
    assert ReferenceObject08.sitemap_attributes_hash.kind_of?(NilClass)
    assert b.sitemap_attributes_hash.kind_of?(NilClass)

  end

end
