require 'test_helper'

class SitemapDefaultsTest < ActiveSupport::TestCase

  ##################################################################################
  test "can get sitemap defaults" do

    class TestObject01 < ApplicationController
    end

    DuckMap::Config.reset

    object = TestObject01.new
    values = object.sitemap_defaults
    assert values[:title].eql?("Untitled")

  end

  ##################################################################################
  test "can override sitemap_defaults method" do

    class TestObject01 < ApplicationController
      def sitemap_defaults(options = {})
        values = super(options)
        values[:title] = "My Title"
        return values
      end
    end

    DuckMap::Config.reset

    object = TestObject01.new
    values = object.sitemap_defaults
    assert values[:title].eql?("My Title")

  end

end




















