require 'test_helper'

class ConfigCopyTest < ActiveSupport::TestCase

  ##################################################################################
  test "should make a copy of sitemap_attributes_hash" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    # make a copy of the class variable values
    values = DuckMap::Config.copy_sitemap_attributes_hash

    # change the class variable values
    DuckMap::Config.sitemap_attributes_hash[:default][:title] = :default_title
    DuckMap::Config.sitemap_attributes_hash[:default][:keywords] = :default_keywords

    DuckMap::Config.sitemap_attributes_hash[:index][:title] = :index_title
    DuckMap::Config.sitemap_attributes_hash[:index][:keywords] = :index_keywords

    # verify the change
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?(:default_title)
    assert DuckMap::Config.sitemap_attributes_hash[:default][:keywords].eql?(:default_keywords)

    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?(:index_title)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:keywords].eql?(:index_keywords)

    # verify the copy did not change
    assert values[:default][:title].eql?(:title)
    assert values[:default][:keywords].eql?(:keywords)

    assert values[:index][:title].eql?(:title)
    assert values[:index][:keywords].eql?(:keywords)

  end

  ##################################################################################
  test "should make a copy of attributes" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    # make a copy of the class variable values
    values = DuckMap::Config.copy_attributes

    # change the class variable values
    DuckMap::Config.title = "new title"
    DuckMap::Config.keywords = "moe larry the cheese"

    # verify the change
    assert DuckMap::Config.title.eql?("new title")
    assert DuckMap::Config.keywords.eql?("moe larry the cheese")

    # verify the copy did not change
    assert values[:title].eql?("Untitled")
    assert values[:keywords].kind_of?(NilClass)

  end

end
















