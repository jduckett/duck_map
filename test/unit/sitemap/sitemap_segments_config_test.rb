require 'test_helper'

class SitemapSegmentsConfigTest < ActiveSupport::TestCase

  ##################################################################################
  test "should set single attribute on :segments" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_segments :default, id: :my_id
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments].blank?
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments].blank?
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments].blank?
  end

  ##################################################################################
  test "should set single attribute on all :segments" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_segments id: :my_id
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments][:id] == :my_id
  end

  ##################################################################################
  test "should set multiple attributes on :segments" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_segments :default, id: :my_id, title: :my_title
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments].blank?
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments].blank?
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments].blank?
  end

  ##################################################################################
  test "should set multiple attributes on all :segments" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_segments id: :my_id, title: :my_title
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments][:title] == :my_title
  end

end




















