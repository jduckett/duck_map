require 'test_helper'

class RouteOwnerTest < ActiveSupport::TestCase

  ##################################################################################
  test "should NOT find sitemap route" do

    Rails.application.routes.routes.clear
    Rails.application.routes.sitemap_filters.reset

    DevCom::Application.routes.draw do

      #sitemap do
      #end
      sitemap

      resources :chicks

      namespace :books do
        #sitemap
        #sitemap :duck do
          resources :drums
        #end
        #sitemap :goose do
        #end

        #namespace :trucks do
          #sitemap :duck do
          #end
          #sitemap :cat do
          #end

          namespace :cars do
            #sitemap
            #sitemap do
            #sitemap :dog do
            #end
            resources :basses

            #end
          end
        #end
      end
    end

    route = Rails.application.routes.routes.find {|route| route.name.eql?("books_cars_basses")}
    #puts route.name
    route_owner = Rails.application.routes.route_owner(route)
    if route_owner.blank?
      #puts "wtf.  blank"
    else
      #puts route_owner.name
    end

    assert true
  end

end
























