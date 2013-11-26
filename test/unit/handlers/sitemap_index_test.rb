require 'test_helper'

class SitemapIndexGeneric < TablelessModel
  #attr_accessible :id, :canonical, :canonical_host, :canonical_port, :changefreq, :description, :keywords, :priority, :title, :url_format, :url_limit, :updated_at

  column :id, :integer

  column :canonical, :string
  column :canonical_host, :string
  column :canonical_port, :integer
  column :changefreq, :string
  column :description, :string
  column :keywords, :string
  column :priority, :string
  column :title, :string
  column :url_format, :string
  column :url_limit, :integer
  column :updated_at, :timestamp

end

class SitemapIndexRequest < ActionDispatch::Request

  def initialize(*args)
    super(*args)
    @env["HTTP_HOST"] = "localhost"
  end

end

class SitemapIndexTest < ActiveSupport::TestCase

  ##################################################################################
  # this test will rely completely on default values from config
  # it will find the first model, however, the model will have nil values, so, none of
  # them are used.
  test "use default values" do

    # leave this stuff here before the class definition or you will be sorry...
    DuckMap::Config.reset
    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      resources :sitemap_index_01_tests
    end

    class SitemapIndex01TestsController < ApplicationController
      def index
        @data_rows = [SitemapIndexGeneric.new]
      end
    end

    route = Rails.application.routes.find_route_via_name("sitemap_index_01_tests")
    assert !route.blank?

    options = { action_name: route.action_name,
                controller_name: route.controller_name,
                model: nil,
                route: route,
                source: :sitemap}

    request = SitemapIndexRequest.new({})
    controller = SitemapIndex01TestsController.new
    controller.request = request
    rows = controller.sitemap_setup(options)

    assert rows.kind_of?(Array)
    assert rows.length > 0
    assert rows.first[:canonical].eql?("http://localhost/sitemap_index_01_tests.html")
    assert rows.first[:canonical_host].nil?
    assert rows.first[:canonical_port].nil?
    assert rows.first[:changefreq].eql?("monthly")
    assert rows.first[:description].nil?
    assert rows.first[:keywords].nil?
    assert rows.first[:lastmod].kind_of?(Time)
    assert rows.first[:loc].eql?("http://localhost/sitemap_index_01_tests.html")
    assert rows.first[:priority].eql?("0.5")
    assert rows.first[:title].eql?("Untitled")
    assert rows.first[:url_format].eql?("html")
    assert rows.first[:url_limit].eql?(50000)

  end

  ##################################################################################
  # test will grab some attribute values from the first model on the controller
  test "use partial first model attribute values" do

    # leave this stuff here before the class definition or you will be sorry...
    DuckMap::Config.reset
    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      resources :sitemap_index_02_tests
    end

    class SitemapIndex02TestsController < ApplicationController
      def index
        @data_rows = [SitemapIndexGeneric.new(
                                              description: "SitemapIndex02TestsController description",
                                              keywords: "this that and the other",
                                              title: "My Title",
                                              updated_at: DateTime.new(2001,1,1,16,04,8,0))]
      end
    end

    route = Rails.application.routes.find_route_via_name("sitemap_index_02_tests")
    assert !route.blank?

    options = { action_name: route.action_name,
                controller_name: route.controller_name,
                model: nil,
                route: route,
                source: :sitemap}

    request = SitemapIndexRequest.new({})
    controller = SitemapIndex02TestsController.new
    controller.request = request
    rows = controller.sitemap_setup(options)

    assert rows.kind_of?(Array)
    assert rows.length > 0
    assert rows.first[:canonical].eql?("http://localhost/sitemap_index_02_tests.html")
    assert rows.first[:canonical_host].nil?
    assert rows.first[:canonical_port].nil?
    assert rows.first[:changefreq].eql?("monthly")
    assert rows.first[:description].eql?("SitemapIndex02TestsController description")
    assert rows.first[:keywords].eql?("this that and the other")
    assert rows.first[:lastmod].eql?(DateTime.new(2001,1,1,16,04,8,0))
    assert rows.first[:loc].eql?("http://localhost/sitemap_index_02_tests.html")
    assert rows.first[:priority].eql?("0.5")
    assert rows.first[:title].eql?("My Title")
    assert rows.first[:url_format].eql?("html")
    assert rows.first[:url_limit].eql?(50000)

  end

  ##################################################################################
  # test will grab all attribute values from the first model on the controller
  test "use full first model attribute values" do

    # leave this stuff here before the class definition or you will be sorry...
    DuckMap::Config.reset
    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      resources :sitemap_index_03_tests
    end

    class SitemapIndex03TestsController < ApplicationController

      acts_as_sitemap :index,
                      canonical: :canonical,
                      canonical_host: :canonical_host,
                      canonical_port: :canonical_port,
                      changefreq: :changefreq,
                      priority: :priority,
                      url_format: :url_format,
                      url_limit: :url_limit

      def index
        @data_rows = [SitemapIndexGeneric.new(
                                              canonical: "http://localhost/my_sitemap_index_03_tests.xml",
                                              canonical_host: "myhost",
                                              canonical_port: 8200,
                                              changefreq: "yearly",
                                              description: "SitemapIndex03TestsController description",
                                              keywords: "this that and the other",
                                              priority: "0.8",
                                              title: "My Title",
                                              url_format: "xml",
                                              url_limit: 4000,
                                              updated_at: DateTime.new(2001,1,1,16,04,8,0))]

      end
    end

    route = Rails.application.routes.find_route_via_name("sitemap_index_03_tests")
    assert !route.blank?

    options = { action_name: route.action_name,
                controller_name: route.controller_name,
                model: nil,
                route: route,
                source: :sitemap}

    request = SitemapIndexRequest.new({})
    controller = SitemapIndex03TestsController.new
    controller.request = request
    rows = controller.sitemap_setup(options)

    assert rows.kind_of?(Array)
    assert rows.length > 0
    assert rows.first[:canonical].eql?("http://localhost/my_sitemap_index_03_tests.xml")
    assert rows.first[:canonical_host].eql?("myhost")
    assert rows.first[:canonical_port].eql?(8200)
    assert rows.first[:changefreq].eql?("yearly")
    assert rows.first[:description].eql?("SitemapIndex03TestsController description")
    assert rows.first[:keywords].eql?("this that and the other")
    assert rows.first[:lastmod].eql?(DateTime.new(2001,1,1,16,04,8,0))
    assert rows.first[:loc].eql?("http://localhost/my_sitemap_index_03_tests.xml")
    assert rows.first[:priority].eql?("0.8")
    assert rows.first[:title].eql?("My Title")
    assert rows.first[:url_format].eql?("xml")
    assert rows.first[:url_limit].eql?(4000)

  end

  ##################################################################################
  # test will ignore grabbing values from the first model.  the values should match the same
  # as the first test: "use default values"
  test "first model: false" do

    # leave this stuff here before the class definition or you will be sorry...
    DuckMap::Config.reset
    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      resources :sitemap_index_04_tests
    end

    class SitemapIndex04TestsController < ApplicationController

      acts_as_sitemap :index,
                      canonical: :canonical,
                      canonical_host: :canonical_host,
                      changefreq: :changefreq,
                      priority: :priority,
                      url_format: :url_format,
                      url_limit: :url_limit, handler: {first_model: false}

      def index
        @data_rows = [SitemapIndexGeneric.new(
                                              canonical: "http://localhost/my_sitemap_index_04_tests.xml",
                                              canonical_host: "myhost",
                                              canonical_port: 8200,
                                              changefreq: "yearly",
                                              description: "SitemapIndex04TestsController description",
                                              keywords: "this that and the other",
                                              priority: "0.8",
                                              title: "My Title",
                                              url_format: "xml",
                                              url_limit: 4000,
                                              updated_at: DateTime.new(2001,1,1,16,04,8,0))]

      end
    end

    route = Rails.application.routes.find_route_via_name("sitemap_index_04_tests")
    assert !route.blank?

    options = { action_name: route.action_name,
                controller_name: route.controller_name,
                model: nil,
                route: route,
                source: :sitemap}

    request = SitemapIndexRequest.new({})
    controller = SitemapIndex04TestsController.new
    controller.request = request
    rows = controller.sitemap_setup(options)

    assert rows.kind_of?(Array)
    assert rows.length > 0
    assert rows.first[:canonical].eql?("http://localhost/sitemap_index_04_tests.html")
    assert rows.first[:canonical_host].nil?
    assert rows.first[:canonical_port].nil?
    assert rows.first[:changefreq].eql?("monthly")
    assert rows.first[:description].nil?
    assert rows.first[:keywords].nil?
    assert rows.first[:lastmod].kind_of?(Time)
    assert rows.first[:loc].eql?("http://localhost/sitemap_index_04_tests.html")
    assert rows.first[:priority].eql?("0.5")
    assert rows.first[:title].eql?("Untitled")
    assert rows.first[:url_format].eql?("html")
    assert rows.first[:url_limit].eql?(50000)

  end


end
