require 'test_helper'

class ActsAsSitemapConfigTest < ActiveSupport::TestCase

  ##################################################################################
  test "acts_as_sitemap without key defaults to :all" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap title: :my_title
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :my_title

    # make sure they are not pointing to the same value somehow
    DuckMap::Config.sitemap_attributes_hash[:default][:title] = :default_title
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == :default_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :my_title

    DuckMap::Config.sitemap_attributes_hash[:index][:title] = :index_title
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == :default_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :index_title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :my_title

    DuckMap::Config.sitemap_attributes_hash[:show][:title] = :show_title
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == :default_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :index_title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :show_title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :my_title

    DuckMap::Config.sitemap_attributes_hash[:new][:title] = :new_title
    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == :default_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :index_title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :show_title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :new_title

  end

  ##################################################################################
  test "should set attribute to string instead of symbol" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap title: "my title"
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == "my title"
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == "my title"
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == "my title"
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == "my title"
  end

  ##################################################################################
  test "should set attribute to nil" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap title: nil
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].nil?
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].nil?
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title].nil?
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title].nil?
  end

  ##################################################################################
  test "should set single attribute to symbol" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, title: :my_title
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == :my_title
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :title
  end

  ##################################################################################
  test "should set single attribute to string" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, title: "my title"
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title] == "my title"
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :title
  end

  ##################################################################################
  test "should set single attribute to nil" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, title: nil
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].nil?
    assert DuckMap::Config.sitemap_attributes_hash[:index][:title] == :title
    assert DuckMap::Config.sitemap_attributes_hash[:show][:title] == :title
    assert DuckMap::Config.sitemap_attributes_hash[:new][:title] == :title
  end

  ##################################################################################
  test "should set single attribute on :handler" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, handler: {action_name: :my_index}
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] == :sitemap_index
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:action_name] == :sitemap_show
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:action_name] == :sitemap_new
  end

  ##################################################################################
  test "should set single attribute on all :handler" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap handler: {action_name: :my_index}
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:show][:handler][:action_name] == :my_index
    assert DuckMap::Config.sitemap_attributes_hash[:new][:handler][:action_name] == :my_index
  end

  ##################################################################################
  test "should set multiple attributes on :handler" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, handler: {action_name: :my_index, first_model: true}
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

    DevCom::Application.routes.draw do
      acts_as_sitemap handler: {action_name: :my_index, first_model: true}
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

  ##################################################################################
  test "should set single attribute on :segments" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, segments: {id: :my_id}
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments].blank?
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments].blank?
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments].blank?
  end

  ##################################################################################
  test "should set single attribute on all :segments" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap segments: {id: :my_id}
    end

    assert DuckMap::Config.sitemap_attributes_hash[:default][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:index][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:show][:segments][:id] == :my_id
    assert DuckMap::Config.sitemap_attributes_hash[:new][:segments][:id] == :my_id
  end

  ##################################################################################
  test "should set multiple attributes on :segments" do
    DuckMap::Config.reset

    DevCom::Application.routes.draw do
      acts_as_sitemap :default, segments: {id: :my_id, title: :my_title}
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

    DevCom::Application.routes.draw do
      acts_as_sitemap segments: {id: :my_id, title: :my_title}
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




















