require 'test_helper'

class RouteSetTest < ActiveSupport::TestCase

  ##################################################################################
  test "should NOT find sitemap route" do

    Dummy::Application.routes.routes.clear

    Dummy::Application.routes.draw do
    end

    assert Rails.application.routes.find_sitemap_route("/sitemap.xml").nil?
    assert Rails.application.routes.find_sitemap_route(:sitemap).nil?

  end

  ##################################################################################
  test "SHOULD find sitemap route" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      sitemap
    end

    assert Rails.application.routes.find_sitemap_route("/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)

  end

  ##################################################################################
  test "SHOULD find sitemap route using default block" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      sitemap do
      end
    end

    assert Rails.application.routes.find_sitemap_route("/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)

  end

  ##################################################################################
  test "SHOULD find sitemap route using named block :sitemap (default)" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      sitemap :sitemap do
      end
    end

    assert Rails.application.routes.find_sitemap_route("/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)

  end

  ##################################################################################
  test "SHOULD find sitemap route using named block :duck" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      sitemap :duck do
      end
    end

    assert Rails.application.routes.find_sitemap_route("/duck.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:duck).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:duck_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("duck").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("duck_sitemap").kind_of?(ActionDispatch::Journey::Route)

    assert Rails.application.routes.find_sitemap_route("/sitemap.xml").kind_of?(ActionDispatch::Journey::Route).blank?
    assert Rails.application.routes.find_sitemap_route(:sitemap).kind_of?(ActionDispatch::Journey::Route).blank?
    assert Rails.application.routes.find_sitemap_route(:sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route).blank?
    assert Rails.application.routes.find_sitemap_route("sitemap").kind_of?(ActionDispatch::Journey::Route).blank?
    assert Rails.application.routes.find_sitemap_route("sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route).blank?
  end

  ##################################################################################
  test "SHOULD find namespaced sitemap route without" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      namespace :books do
        sitemap
      end
    end

    assert Rails.application.routes.find_sitemap_route("/books/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)
  end

  ##################################################################################
  test "SHOULD find namespaced sitemap route using default block" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      namespace :books do
        sitemap do
        end
      end
    end

    assert Rails.application.routes.find_sitemap_route("/books/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)
  end

  ##################################################################################
  test "SHOULD find namespaced sitemap route using named block :sitemap (default)" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      namespace :books do
        sitemap :sitemap do
        end
      end
    end

    assert Rails.application.routes.find_sitemap_route("/books/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)
  end

  ##################################################################################
  test "SHOULD find namespaced sitemap route using named block :duck" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do
      namespace :books do
        sitemap :duck do
        end
      end
    end

    assert Rails.application.routes.find_sitemap_route("/books/duck.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_duck).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_duck_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_duck").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_duck_sitemap").kind_of?(ActionDispatch::Journey::Route)
  end

  ##################################################################################
  test "SHOULD find combination deeply namespaced sitemap routes" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do

      sitemap do
      end

      namespace :books do
        sitemap :duck do
        end
        sitemap :goose do
        end

        namespace :trucks do
          sitemap :duck do
          end
          sitemap :cat do
          end

          namespace :cars do
            sitemap :dog do
            end
          end
        end

      end
    end

    assert Rails.application.routes.find_sitemap_route("/sitemap.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:sitemap_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("sitemap_sitemap").kind_of?(ActionDispatch::Journey::Route)

    assert Rails.application.routes.find_sitemap_route("/books/duck.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_duck).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_duck_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_duck").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_duck_sitemap").kind_of?(ActionDispatch::Journey::Route)

    assert Rails.application.routes.find_sitemap_route("/books/goose.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_goose).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_goose_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_goose").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_goose_sitemap").kind_of?(ActionDispatch::Journey::Route)

    assert Rails.application.routes.find_sitemap_route("/books/trucks/duck.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_trucks_duck).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_trucks_duck_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_trucks_duck").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_trucks_duck_sitemap").kind_of?(ActionDispatch::Journey::Route)

    assert Rails.application.routes.find_sitemap_route("/books/trucks/cat.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_trucks_cat).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_trucks_cat_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_trucks_cat").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_trucks_cat_sitemap").kind_of?(ActionDispatch::Journey::Route)

    assert Rails.application.routes.find_sitemap_route("/books/trucks/cars/dog.xml").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_trucks_cars_dog).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route(:books_trucks_cars_dog_sitemap).kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_trucks_cars_dog").kind_of?(ActionDispatch::Journey::Route)
    assert Rails.application.routes.find_sitemap_route("books_trucks_cars_dog_sitemap").kind_of?(ActionDispatch::Journey::Route)
  end

  ##################################################################################
  test "sitemap SHOULD contain one route" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do

      sitemap

      root to: "home#index"

    end

    sitemap_route = Rails.application.routes.find_sitemap_route("/sitemap.xml")
    list = Rails.application.routes.sitemap_routes(sitemap_route)
    assert list.kind_of?(Array)
    assert list.length == 1
    assert list.first.name == "root"

  end

  ##################################################################################
  test "sitemap with block SHOULD contain one route" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do

      sitemap

      root to: "home#index"

    end

    sitemap_route = Rails.application.routes.find_sitemap_route("/sitemap.xml")
    list = Rails.application.routes.sitemap_routes(sitemap_route)
    assert list.kind_of?(Array)
    assert list.length == 1
    assert list.first.name == "root"

  end

  ##################################################################################
  test "sitemap SHOULD contain three routes" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do

      sitemap

      root to: "home#index"
      resources :books

    end

    sitemap_route = Rails.application.routes.find_sitemap_route("/sitemap.xml")
    list = Rails.application.routes.sitemap_routes(sitemap_route)
    assert list.kind_of?(Array)
    assert list.length == 3

    assert list.find {|route| route.name.eql?("root")}
    assert list.find {|route| route.name.eql?("books")}   # index
    assert list.find {|route| route.name.eql?("book")}    # show

  end

  ##################################################################################
  test "sitemap with block SHOULD contain three routes" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do

      sitemap do

        root to: "home#index"
        resources :books

      end

    end

    sitemap_route = Rails.application.routes.find_sitemap_route("/sitemap.xml")
    list = Rails.application.routes.sitemap_routes(sitemap_route)
    assert list.kind_of?(Array)
    assert list.length == 3

    assert list.find {|route| route.name.eql?("root")}
    assert list.find {|route| route.name.eql?("books")}   # index
    assert list.find {|route| route.name.eql?("book")}    # show

  end

  ##################################################################################
  test "namespaced sitemap SHOULD contain three route" do

    Dummy::Application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    Dummy::Application.routes.draw do

      namespace :duck do
        sitemap do

          root to: "home#index"
          resources :books

        end
      end

    end

    sitemap_route = Rails.application.routes.find_sitemap_route("/duck/sitemap.xml")
    list = Rails.application.routes.sitemap_routes(sitemap_route)
    assert list.kind_of?(Array)
    assert list.length == 3

    assert list.find {|route| route.name.eql?("duck_root")}
    assert list.find {|route| route.name.eql?("duck_books")}   # index
    assert list.find {|route| route.name.eql?("duck_book")}    # show

  end

end
























