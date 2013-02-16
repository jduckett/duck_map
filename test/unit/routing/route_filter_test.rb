require 'test_helper'

class RouteFilterTest < ActiveSupport::TestCase
  test "the truth" do

    DevCom::Application.routes.routes.clear
    DevCom::Application.routes.sitemap_filters.reset

    DevCom::Application.routes.draw do

      include_actions [:new, :edit]

    end

    assert true
  end
end
