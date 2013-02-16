require 'test_helper'

class ActionControllerTestObject < ActionController::TestCase
  include DuckMap::ControllerHelpers

  def inline_title
    self.sitemap_meta_data = {title: "duck"}
  end

  def key_title
    self.sitemap_meta_data = {}
    self.sitemap_meta_data[:title] = "duck"
  end

  def inline_keywords
    self.sitemap_meta_data = {keywords: "bike car truck"}
  end

  def key_keywords
    self.sitemap_meta_data = {}
    self.sitemap_meta_data[:keywords] = "bike car truck"
  end

  def inline_description
    self.sitemap_meta_data = {description: "this is my description"}
  end

  def key_description
    self.sitemap_meta_data = {}
    self.sitemap_meta_data[:description] = "this is my description"
  end

  def inline_lastmod
    self.sitemap_meta_data = {lastmod: DateTime.new(2001,1,1,16,04,8,0)}
  end

  def key_lastmod
    self.sitemap_meta_data = {}
    self.sitemap_meta_data[:lastmod] = DateTime.new(2001,1,1,16,04,8,0)
  end

  def inline_all
    self.sitemap_meta_data = {title: "duck",
                              keywords: "bike car truck",
                              description: "this is my description",
                              lastmod: DateTime.new(2001,1,1,16,04,8,0)}
  end

  def key_all
    self.sitemap_meta_data = {}
    self.sitemap_meta_data[:title] = "duck"
    self.sitemap_meta_data[:keywords] = "bike car truck"
    self.sitemap_meta_data[:description] = "this is my description"
    self.sitemap_meta_data[:lastmod] = DateTime.new(2001,1,1,16,04,8,0)
  end

end

class ActionViewTestObject < ActionView::TestCase
  include DuckMap::ActionViewHelpers
end

class SitemapMetaTagTest < ActiveSupport::TestCase

  test "simulate inline title" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.inline_title

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_title.eql?("<title>duck</title>")
  end

  test "simulate key title" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.key_title

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_title.eql?("<title>duck</title>")
  end

  test "simulate inline keywords" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.inline_keywords

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_keywords.eql?(%(<meta content="bike car truck" name="keywords" />))
  end

  test "simulate key keywords" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.key_keywords

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_keywords.eql?(%(<meta content="bike car truck" name="keywords" />))
  end

  test "simulate inline description" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.inline_description

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_description.eql?(%(<meta content="this is my description" name="description" />))
  end

  test "simulate key description" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.key_description

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_description.eql?(%(<meta content="this is my description" name="description" />))
  end

  test "simulate inline lastmod" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.inline_lastmod

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_lastmod.eql?(%(<meta content="2001-01-01T16:04:08+00:00" name="Last-Modified" />))
  end

  test "simulate key lastmod" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.key_lastmod

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_lastmod.eql?(%(<meta content="2001-01-01T16:04:08+00:00" name="Last-Modified" />))
  end

  test "simulate inline all" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.inline_all

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_title.eql?("<title>duck</title>")
    assert obj.sitemap_meta_keywords.eql?(%(<meta content="bike car truck" name="keywords" />))
    assert obj.sitemap_meta_description.eql?(%(<meta content="this is my description" name="description" />))
    assert obj.sitemap_meta_lastmod.eql?(%(<meta content="2001-01-01T16:04:08+00:00" name="Last-Modified" />))
  end

  test "simulate key all" do
    controller_obj = ActionControllerTestObject.new({})
    controller_obj.key_all

    obj = ActionViewTestObject.new({})
    obj.controller = controller_obj

    assert obj.sitemap_meta_title.eql?("<title>duck</title>")
    assert obj.sitemap_meta_keywords.eql?(%(<meta content="bike car truck" name="keywords" />))
    assert obj.sitemap_meta_description.eql?(%(<meta content="this is my description" name="description" />))
    assert obj.sitemap_meta_lastmod.eql?(%(<meta content="2001-01-01T16:04:08+00:00" name="Last-Modified" />))
  end
end
