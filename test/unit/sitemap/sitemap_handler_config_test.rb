require 'test_helper'

class SitemapHandlerConfigTest < ActiveSupport::TestCase

  ##################################################################################
  test "should set single attribute on :handler" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_handler :default, action_name: :my_index
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] == :sitemap_index
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:action_name] == :sitemap_show
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:action_name] == :sitemap_new
  end

  ##################################################################################
  test "should set single attribute on all :handler" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_handler action_name: :my_index
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:action_name] == :my_index
  end

  ##################################################################################
  test "should set multiple attributes on :handler" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_handler :default, action_name: :my_index, first_model: true
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:first_model]
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] == :sitemap_index
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:first_model]
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:action_name] == :sitemap_show
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:first_model]
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:action_name] == :sitemap_new
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:first_model]
  end

  ##################################################################################
  test "should set multiple attributes on all :handler" do
    DuckMap::Config.reset

    Dummy::Application.routes.draw do
      sitemap_handler action_name: :my_index, first_model: true
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:first_model]
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:first_model]
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:first_model]
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:first_model]
  end

end




















