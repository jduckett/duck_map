class SitemapBaseController < ApplicationController

  include DuckMap::SitemapControllerHelpers
  helper DuckMap::Model
  helper DuckMap::SitemapHelpers

  rescue_from ActionView::MissingTemplate do |exception|
    respond_to do |format|
      format.xml { render :template => "sitemap/default_template"}
    end
  end

end
