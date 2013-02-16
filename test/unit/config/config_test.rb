require 'test_helper'

class ConfigTest < ActiveSupport::TestCase

  ##################################################################################
  test "default value for attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.title == "Untitled"
  end

  ##################################################################################
  test "set :title attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.title == "Untitled"

    DuckMap::Config.title = "My App"
    assert DuckMap::Config.title == "My App"
  end

  ##################################################################################
  test "SHOULD set :title via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.title == "Untitled"

    DevCom::Application.routes.draw do
      title "My App"
    end

    assert DuckMap::Config.title == "My App"
  end

  ##################################################################################
  test "set :keywords attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.keywords.nil?

    DuckMap::Config.keywords = "Rails, Ruby"
    assert DuckMap::Config.keywords == "Rails, Ruby"
  end

  ##################################################################################
  test "SHOULD set :keywords via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.keywords.nil?

    DevCom::Application.routes.draw do
      keywords "Rails, Ruby"
    end

    assert DuckMap::Config.keywords == "Rails, Ruby"
  end

  ##################################################################################
  test "set :description attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.description.nil?

    DuckMap::Config.description = "This is my app"
    assert DuckMap::Config.description == "This is my app"
  end

  ##################################################################################
  test "SHOULD set :description via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.description.nil?

    DevCom::Application.routes.draw do
      description "This is my app"
    end

    assert DuckMap::Config.description == "This is my app"
  end

  ##################################################################################
  test "set :lastmod attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.lastmod.kind_of?(Time)

    DuckMap::Config.lastmod = nil
    assert DuckMap::Config.lastmod.nil?

    DuckMap::Config.lastmod = Time.now
    assert DuckMap::Config.lastmod.kind_of?(Time)
  end

  ##################################################################################
  test "SHOULD set :lastmod to nil via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.lastmod.kind_of?(Time)

    DevCom::Application.routes.draw do
      lastmod nil
    end

    assert DuckMap::Config.lastmod.nil?
  end

  ##################################################################################
  test "SHOULD NOT set :lastmod attribute to String" do
    # this is just a blank test to remind me that setting attribute values
    # directly does not have the same behavior as using the configuration helper methods.
    # setting lastmod to a String would use the String value
    # doing that would make code blow up, so, don't.
    # just a reminder.  i have no intention of changing this unless absolutely required.
    # If I need to in the future, it will happen on the method_missing method of DuckMap::Config
  end

  ##################################################################################
  test "SHOULD set :lastmod to Time via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.lastmod.kind_of?(Time)

    DuckMap::Config.lastmod = nil
    assert DuckMap::Config.lastmod.nil?

    DevCom::Application.routes.draw do
      lastmod Time.now
    end

    assert DuckMap::Config.lastmod.kind_of?(Time)
  end

  ##################################################################################
  test "SHOULD set :lastmod to String via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.lastmod.kind_of?(Time)

    DuckMap::Config.lastmod = nil
    assert DuckMap::Config.lastmod.nil?

    DevCom::Application.routes.draw do
      lastmod "10/12/2012 04:00:00"
    end

    assert DuckMap::Config.lastmod.kind_of?(Time)
    assert DuckMap::Config.lastmod.to_s.include?("2012-10-12 04:00:00")
  end

  ##################################################################################
  test "set :changefreq attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.changefreq == "monthly"

    DuckMap::Config.changefreq = "yearly"
    assert DuckMap::Config.changefreq == "yearly"
  end

  ##################################################################################
  test "SHOULD set :changefreq via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.changefreq == "monthly"

    DevCom::Application.routes.draw do
      changefreq "yearly"
    end

    assert DuckMap::Config.changefreq == "yearly"
  end

  ##################################################################################
  test "set :priority attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.priority == "0.5"

    DuckMap::Config.priority = "0.4"
    assert DuckMap::Config.priority == "0.4"
  end

  ##################################################################################
  test "SHOULD set :priority via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.priority == "0.5"

    DevCom::Application.routes.draw do
      priority "0.4"
    end

    assert DuckMap::Config.priority == "0.4"
  end

  ##################################################################################
  test "SHOULD set :priority as numeric value via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.priority == "0.5"

    DevCom::Application.routes.draw do
      priority 0.2
    end

    assert DuckMap::Config.priority == "0.2"
  end

  ##################################################################################
  test "set :canonical attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.canonical.nil?

    DuckMap::Config.canonical = "http://localhost/"
    assert DuckMap::Config.canonical == "http://localhost/"
  end

  ##################################################################################
  test "SHOULD set :canonical via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.canonical.nil?

    DevCom::Application.routes.draw do
      canonical "http://localhost/"
    end

    assert DuckMap::Config.canonical == "http://localhost/"
  end

  ##################################################################################
  test "set :canonical_host attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.canonical_host.nil?

    DuckMap::Config.canonical_host = "example.com"
    assert DuckMap::Config.canonical_host == "example.com"
  end

  ##################################################################################
  test "set :canonical_port attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.canonical_port.nil?

    DuckMap::Config.canonical_port = 8080
    assert DuckMap::Config.canonical_port.eql?(8080)
  end

  ##################################################################################
  test "SHOULD set :canonical_host via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.canonical_host.nil?

    DevCom::Application.routes.draw do
      canonical_host "example.com"
    end

    assert DuckMap::Config.canonical_host == "example.com"
  end

  ##################################################################################
  test "SHOULD set :canonical_port via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.canonical_port.nil?

    DevCom::Application.routes.draw do
      canonical_port 8080
    end

    assert DuckMap::Config.canonical_port.eql?(8080)
  end

  ##################################################################################
  test "set :url_format attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.url_format == "html"

    DuckMap::Config.url_format = "xml"
    assert DuckMap::Config.url_format == "xml"
  end

  ##################################################################################
  test "SHOULD set :url_format via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.url_format == "html"

    DevCom::Application.routes.draw do
      url_format "xml"
    end

    assert DuckMap::Config.url_format == "xml"
  end

  ##################################################################################
  test "SHOULD set :url_format to nil via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.url_format == "html"

    DevCom::Application.routes.draw do
      url_format nil
    end

    assert DuckMap::Config.url_format.nil?
  end

  ##################################################################################
  test "set :url_limit attribute" do
    DuckMap::Config.reset
    assert DuckMap::Config.url_limit == 50000

    DuckMap::Config.url_limit = 10000
    assert DuckMap::Config.url_limit == 10000
  end

  ##################################################################################
  test "SHOULD set :url_limit via config" do
    DuckMap::Config.reset
    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    assert DuckMap::Config.url_limit == 50000

    DevCom::Application.routes.draw do
      url_limit 10000
    end

    assert DuckMap::Config.url_limit == 10000
  end

  ##################################################################################
  test "set attribute on DuckMap::Config.sitemap_attributes_hash" do
    # set it here, because, the default values may have been changed by another test
    DuckMap::Config.reset

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?(:title)
    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name].eql?(:sitemap_index)
    assert !DuckMap::Config.sitemap_attributes_hash[:default][:handler][:first_model]

    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?(:title)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name].eql?(:sitemap_index)
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:first_model]

    DuckMap::Config.sitemap_attributes_hash[:default][:title] = "default title"
    DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name] = :default_index
    DuckMap::Config.sitemap_attributes_hash[:default][:handler][:first_model] = true

    DuckMap::Config.sitemap_attributes_hash[:index][:title] = "index title"
    DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name] = :index_index
    DuckMap::Config.sitemap_attributes_hash[:index][:handler][:first_model] = false

    assert DuckMap::Config.sitemap_attributes_hash[:default][:title].eql?("default title")
    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:action_name].eql?(:default_index)
    assert DuckMap::Config.sitemap_attributes_hash[:default][:handler][:first_model]

    assert DuckMap::Config.sitemap_attributes_hash[:index][:title].eql?("index title")
    assert DuckMap::Config.sitemap_attributes_hash[:index][:handler][:action_name].eql?(:index_index)
    assert !DuckMap::Config.sitemap_attributes_hash[:index][:handler][:first_model]
  end

end
















