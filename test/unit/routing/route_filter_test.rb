require 'test_helper'

class RouteFilterTest < ActiveSupport::TestCase

  ##################################################################################
  test "exclude :get" do

    DevCom::Application.routes.routes.clear
    DevCom::Application.routes.sitemap_filters.reset

    DevCom::Application.routes.draw do

      exclude_verbs :get
      sitemap

      root to: 'home#index'
      resources :faqs

    end

    sitemap_route = DevCom::Application.routes.find_route_via_path("/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)

    # this one will pass cuz it does not have a verb_symbol.  not going to investigate why
    assert routes.find {|x| x.name.eql?("root")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("faq")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("faqs")}.kind_of?(Journey::Route)

  end

  ##################################################################################
  test "exclude :get include :show, :new fail" do

    DevCom::Application.routes.routes.clear
    DevCom::Application.routes.sitemap_filters.reset

    DevCom::Application.routes.draw do

      # verbs will trump actions
      # you might expect :show and :new to be included, however, since :get is a verb
      # it will all actions that are :get
      # the only way to get around this problem is to specify directly on the route
      exclude_verbs :get
      include_actions :show, :new
      sitemap

      root to: 'home#index'
      resources :faqs

    end

    sitemap_route = DevCom::Application.routes.find_route_via_path("/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)

    # this one will pass cuz it does not have a verb_symbol.  not going to investigate why
    assert routes.find {|x| x.name.eql?("root")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("faq")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("faqs")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("new_faq")}.kind_of?(Journey::Route)

  end

  ##################################################################################
  test "exclude :get include :show, :new succeed" do

    DevCom::Application.routes.routes.clear
    DevCom::Application.routes.sitemap_filters.reset

    DevCom::Application.routes.draw do

      # verbs will trump actions
      # you might expect :show and :new to be included, however, since :get is a verb
      # it will all actions that are :get
      # the only way to get around this problem is to specify directly on the route
      exclude_verbs :get
      include_actions :show, :new
      sitemap

      root to: 'home#index'
      resources :faqs, include_actions: [:show, :new, :index]
      resources :books

    end

    sitemap_route = DevCom::Application.routes.find_route_via_path("/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)

    # this one will pass cuz it does not have a verb_symbol.  not going to investigate why
    assert routes.find {|x| x.name.eql?("root")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("faq")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("faqs")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("new_faq")}.kind_of?(Journey::Route)

    assert !routes.find {|x| x.name.eql?("book")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("books")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("new_book")}.kind_of?(Journey::Route)

  end

  ##################################################################################
  test "big ass test" do

    DevCom::Application.routes.routes.clear
    DevCom::Application.routes.sitemap_filters.reset

    DevCom::Application.routes.draw do

      sitemap

      root to: 'home#index'                   # default sitemap   /sitemap.xml
      resources :faqs

      namespace :products do

        sitemap do                            # /products/sitemap.xml

          exclude_actions :index

          resources :papers
          resources :pencils

          namespace :audio do

            sitemap do                        # /products/audio/sitemap.xml

              include_actions :new
              exclude_actions :show

              resources :accessories
              resources :head_phones
              resources :speakers
            end

          end

          namespace :video do

            sitemap do                        # /products/video/sitemap.xml

              include_actions :index, :edit

              resources :accessories
              resources :dvd_players

              sitemap :bluray do              # /products/video/bluray.xml

                include_actions :new

                resources :bluray_players
              end

            end

          end

        end

      end

    end

    sitemap_route = DevCom::Application.routes.find_route_via_path("/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)
    assert routes.find {|x| x.name.eql?("root")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("faq")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("faqs")}.kind_of?(Journey::Route)

    sitemap_route = DevCom::Application.routes.find_route_via_path("/products/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)
    assert routes.find {|x| x.name.eql?("products_paper")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_papers")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("products_pencil")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_pencils")}.kind_of?(Journey::Route)

    sitemap_route = DevCom::Application.routes.find_route_via_path("/products/audio/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)

    assert !routes.find {|x| x.name.eql?("products_audio_accessory")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_audio_accessories")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("new_products_audio_accessory")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_audio_head_phone")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_audio_head_phones")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("new_products_audio_head_phone")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_audio_speaker")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_audio_speakers")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("new_products_audio_speaker")}.kind_of?(Journey::Route)

    sitemap_route = DevCom::Application.routes.find_route_via_path("/products/video/sitemap.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)

    assert !routes.find {|x| x.name.eql?("products_video_bluray_player")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_video_bluray_players")}.kind_of?(Journey::Route)

    assert routes.find {|x| x.name.eql?("products_video_accessory")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("products_video_accessories")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("edit_products_video_accessory")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("new_products_video_accessory")}.kind_of?(Journey::Route)

    assert routes.find {|x| x.name.eql?("products_video_dvd_player")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("products_video_dvd_players")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("edit_products_video_dvd_player")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("new_products_video_dvd_player")}.kind_of?(Journey::Route)

    sitemap_route = DevCom::Application.routes.find_route_via_path("/products/video/bluray.xml")
    assert sitemap_route.kind_of?(Journey::Route)

    routes = DevCom::Application.routes.sitemap_routes(sitemap_route)

    assert routes.find {|x| x.name.eql?("products_video_bluray_player")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("products_video_bluray_players")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("edit_products_video_bluray_player")}.kind_of?(Journey::Route)
    assert routes.find {|x| x.name.eql?("new_products_video_bluray_player")}.kind_of?(Journey::Route)

    assert !routes.find {|x| x.name.eql?("products_video_accessory")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_video_accessories")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("edit_products_video_accessory")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("new_products_video_accessory")}.kind_of?(Journey::Route)

    assert !routes.find {|x| x.name.eql?("products_video_dvd_player")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("products_video_dvd_players")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("edit_products_video_dvd_player")}.kind_of?(Journey::Route)
    assert !routes.find {|x| x.name.eql?("new_products_video_dvd_player")}.kind_of?(Journey::Route)

  end

end






















