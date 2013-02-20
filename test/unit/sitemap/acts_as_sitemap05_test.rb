require 'test_helper'

class ActsAsSitemap05Test < ActiveSupport::TestCase

  #################################################################################
  test "acts_as_sitemap with block to all handlers" do

    DuckMap::Config.reset

    DuckMap::Config.acts_as_sitemap do
      []  # can be anything.  empty array is ok
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:block].kind_of?(Proc)
    assert DuckMap::Config.sitemap_attributes_hash[:edit][:handler][:block].kind_of?(Proc)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:block].kind_of?(Proc)
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:block].kind_of?(Proc)
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:block].kind_of?(Proc)

  end

  #################################################################################
  test "acts_as_sitemap with block to a single handler" do

    DuckMap::Config.reset

    DuckMap::Config.acts_as_sitemap :index do
      []  # can be anything.  empty array is ok
    end

    assert !DuckMap::Config.sitemap_attributes_hash[:default][:handler][:block].kind_of?(Proc)
    assert !DuckMap::Config.sitemap_attributes_hash[:edit][:handler][:block].kind_of?(Proc)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:block].kind_of?(Proc)
    assert !DuckMap::Config.sitemap_attributes_hash[:new][:handler][:block].kind_of?(Proc)
    assert !DuckMap::Config.sitemap_attributes_hash[:show][:handler][:block].kind_of?(Proc)

  end

  #################################################################################
  test "acts_as_sitemap lastmod as String" do

    DuckMap::Config.reset

    Rails.application.routes.draw do
      acts_as_sitemap lastmod: "02/16/2013"
    end

    value = DuckMap::Config.sitemap_attributes_hash[:default][:lastmod]
    assert value.kind_of?(Time)
    assert value.day.eql?(16)
    assert value.month.eql?(2)
    assert value.year.eql?(2013)

  end

end










