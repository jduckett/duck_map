require 'test_helper'

class ActsAsSitemap04Test < ActiveSupport::TestCase

  ##################################################################################
  test "acts_as_sitemap separate keys same value" do

    DuckMap::Config.reset

    DuckMap::Config.acts_as_sitemap :default, title: :my_title
    DuckMap::Config.acts_as_sitemap :edit, title: :my_title
    DuckMap::Config.acts_as_sitemap :index, title: :my_title
    DuckMap::Config.acts_as_sitemap :new, title: :my_title
    DuckMap::Config.acts_as_sitemap :show, title: :my_title

    assert HashModel.verify("unit/sitemap/models/test01", DuckMap::Config.sitemap_attributes_hash)

  end

  ##################################################################################
  test "acts_as_sitemap separate keys separate values" do

    DuckMap::Config.reset

    DuckMap::Config.acts_as_sitemap :default, title: :default_title
    DuckMap::Config.acts_as_sitemap :edit, title: :edit_title
    DuckMap::Config.acts_as_sitemap :index, title: :index_title
    DuckMap::Config.acts_as_sitemap :new, title: :new_title
    DuckMap::Config.acts_as_sitemap :show, title: :show_title

    assert HashModel.verify("unit/sitemap/models/test04", DuckMap::Config.sitemap_attributes_hash)

  end

  ##################################################################################
  test "acts_as_sitemap multiple keys multiple values" do

    DuckMap::Config.reset

    DuckMap::Config.acts_as_sitemap :default, title: :default_title,
                                              keywords: "moe larry the cheese",
                                              description: "this is a test",
                                              priority: "0.4",
                                              changefreq: "monthly"

    DuckMap::Config.acts_as_sitemap :edit, title: "edit_title",
                                              keywords: "rails duck_map",
                                              description: "testing duck map",
                                              priority: "0.6",
                                              changefreq: "yearly",
                                              canonical: "http://localhost:3000/",
                                              canonical_host: "example.com",
                                              url_format: "xml",
                                              url_limit: 4000

    DuckMap::Config.acts_as_sitemap :index, title: nil,
                                              keywords: nil,
                                              description: nil,
                                              priority: nil,
                                              changefreq: nil,
                                              lastmod: nil,
                                              url_limit: 8000

    DuckMap::Config.acts_as_sitemap :new, title: :new_title,
                                              handler: {action_name: nil, first_model: false}

    DuckMap::Config.acts_as_sitemap :show, title: :show_title,
                                              handler: {action_name: :my_action,
                                                        first_model: false,
                                                        my_attribute: :my_value},
                                              segments: {id: :my_id,
                                                          sub_id: :book_id,
                                                          title: :my_title}

    assert HashModel.verify("unit/sitemap/models/test05", DuckMap::Config.sitemap_attributes_hash)

  end

  ##################################################################################
  test "config block acts_as_sitemap title: :my_title" do

    DuckMap::Config.reset

    Rails.application.routes.draw do
      acts_as_sitemap :default, title: :default_title,
                                keywords: "moe larry the cheese",
                                description: "this is a test",
                                priority: "0.4",
                                changefreq: "monthly"

      acts_as_sitemap :edit, title: "edit_title",
                                keywords: "rails duck_map",
                                description: "testing duck map",
                                priority: "0.6",
                                changefreq: "yearly",
                                canonical: "http://localhost:3000/",
                                canonical_host: "example.com",
                                url_format: "xml",
                                url_limit: 4000

      acts_as_sitemap :index, title: nil,
                                keywords: nil,
                                description: nil,
                                priority: nil,
                                changefreq: nil,
                                lastmod: nil,
                                url_limit: 8000

      acts_as_sitemap :new, title: :new_title,
                                handler: {action_name: nil, first_model: false}

      acts_as_sitemap :show, title: :show_title,
                                handler: {action_name: :my_action,
                                          first_model: false,
                                          my_attribute: :my_value},
                                segments: {id: :my_id,
                                            sub_id: :book_id,
                                            title: :my_title}
    end

    assert HashModel.verify("unit/sitemap/models/test05", DuckMap::Config.sitemap_attributes_hash)

  end

  ##################################################################################
  test "class acts_as_sitemap title: :my_title" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class ActsAsSitemap04TestObject01
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
      include DuckMap::SitemapObject

      acts_as_sitemap :default, title: :default_title,
                                keywords: "moe larry the cheese",
                                description: "this is a test",
                                priority: "0.4",
                                changefreq: "monthly"

      acts_as_sitemap :edit, title: "edit_title",
                                keywords: "rails duck_map",
                                description: "testing duck map",
                                priority: "0.6",
                                changefreq: "yearly",
                                canonical: "http://localhost:3000/",
                                canonical_host: "example.com",
                                url_format: "xml",
                                url_limit: 4000

      acts_as_sitemap :index, title: nil,
                                keywords: nil,
                                description: nil,
                                priority: nil,
                                changefreq: nil,
                                lastmod: nil,
                                url_limit: 8000

      acts_as_sitemap :new, title: :new_title,
                                handler: {action_name: nil, first_model: false}

      acts_as_sitemap :show, title: :show_title,
                                handler: {action_name: :my_action,
                                          first_model: false,
                                          my_attribute: :my_value},
                                segments: {id: :my_id,
                                            sub_id: :book_id,
                                            title: :my_title}

    end

    a = ActsAsSitemap04TestObject01.new

    assert HashModel.verify("unit/sitemap/models/test05", a.sitemap_attributes_hash)

  end

  ##################################################################################
  test "object acts_as_sitemap title: :my_title" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class ActsAsSitemap01TestObject02
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
      include DuckMap::SitemapObject

      acts_as_sitemap :default, title: :default_title,
                                keywords: "moe larry the cheese",
                                description: "this is a test",
                                priority: "0.4",
                                changefreq: "monthly"

      acts_as_sitemap :edit, title: "edit_title",
                                keywords: "rails duck_map",
                                description: "testing duck map",
                                priority: "0.6",
                                changefreq: "yearly",
                                canonical: "http://localhost:3000/",
                                canonical_host: "example.com",
                                url_format: "xml",
                                url_limit: 4000

      acts_as_sitemap :index, title: nil,
                                keywords: nil,
                                description: nil,
                                priority: nil,
                                changefreq: nil,
                                lastmod: nil,
                                url_limit: 8000

      acts_as_sitemap :new, title: :new_title,
                                handler: {action_name: nil, first_model: false}

      acts_as_sitemap :show, title: :show_title,
                                handler: {action_name: :my_action,
                                          first_model: false,
                                          my_attribute: :my_value},
                                segments: {id: :my_id,
                                            sub_id: :book_id,
                                            title: :my_title}

    end

    assert HashModel.verify("unit/sitemap/models/test05", ActsAsSitemap01TestObject02.sitemap_attributes_hash)

  end

  ##################################################################################
  test "sitemap_handler and sitemap_segments" do

    # reset here in case other tests bigfoot the class variables.
    DuckMap::Config.reset

    class ActsAsSitemap04TestObject01
      include DuckMap::InheritableClassAttributes
      include DuckMap::Attributes
      include DuckMap::SitemapObject

      acts_as_sitemap :default, title: :default_title,
                                keywords: "moe larry the cheese",
                                description: "this is a test",
                                priority: "0.4",
                                changefreq: "monthly"

      acts_as_sitemap :edit, title: "edit_title",
                                keywords: "rails duck_map",
                                description: "testing duck map",
                                priority: "0.6",
                                changefreq: "yearly",
                                canonical: "http://localhost:3000/",
                                canonical_host: "example.com",
                                url_format: "xml",
                                url_limit: 4000

      acts_as_sitemap :index, title: nil,
                                keywords: nil,
                                description: nil,
                                priority: nil,
                                changefreq: nil,
                                lastmod: nil,
                                url_limit: 8000

      acts_as_sitemap :new, title: :new_title
      sitemap_handler :new, action_name: nil, first_model: false

      acts_as_sitemap :show, title: :show_title
      sitemap_handler :show, action_name: :my_action, first_model: false, my_attribute: :my_value
      sitemap_segments :show, id: :my_id, sub_id: :book_id, title: :my_title

    end

    a = ActsAsSitemap04TestObject01.new

    assert HashModel.verify("unit/sitemap/models/test05", a.sitemap_attributes_hash)

  end

end










