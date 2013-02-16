require 'test_helper'

class StaticLastmodTest < ActiveSupport::TestCase

  ##################################################################################
  test "should NOT find key" do

    class TestObject01
      include DuckMap::ControllerHelpers
    end

    object = TestObject01.new
    assert object.sitemap_static_lastmod("home", "show").nil?
    assert object.sitemap_static_lastmod("books", "update").nil?

  end

  ##################################################################################
  test "should find key" do

    class TestObject01
      include DuckMap::ControllerHelpers
    end

    object = TestObject01.new
    value = object.sitemap_static_lastmod("home", "index")
    assert value.kind_of?(Time)
    assert value.to_s(:sitemap_locale).eql?(LastmodSetup::SITEMAP_LOCALE[:sitemap][:home][:index])

    value = object.sitemap_static_lastmod("books", "edit")
    assert value.kind_of?(Time)
    assert value.to_s(:sitemap_locale).eql?(LastmodSetup::SITEMAP_LOCALE[:sitemap][:books][:edit])

    value = object.sitemap_static_lastmod("books", "index")
    assert value.kind_of?(Time)
    assert value.to_s(:sitemap_locale).eql?(LastmodSetup::SITEMAP_LOCALE[:sitemap][:books][:index])

    value = object.sitemap_static_lastmod("books", "new")
    assert value.kind_of?(Time)
    assert value.to_s(:sitemap_locale).eql?(LastmodSetup::SITEMAP_LOCALE[:sitemap][:books][:new])

    value = object.sitemap_static_lastmod("books", "show")
    assert value.kind_of?(Time)
    assert value.to_s(:sitemap_locale).eql?(LastmodSetup::SITEMAP_LOCALE[:sitemap][:books][:show])

  end
end








