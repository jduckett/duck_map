module DuckMap
  extend ActiveSupport::Autoload

  eager_autoload do

    autoload :ActionViewHelpers, 'duck_map/view_helpers'
    autoload :ArrayHelper, 'duck_map/array_helper'
    autoload :Attributes, 'duck_map/attributes'
    autoload :ClassHelpers, 'duck_map/class_helpers'
    autoload :Config, 'duck_map/config'
    autoload :ConfigHelpers, 'duck_map/config'
    autoload :ControllerHelpers, 'duck_map/controller_helpers'
    autoload :Expressions, 'duck_map/expressions'
    autoload :FilterStack, 'duck_map/filter_stack'
    autoload :Handlers, 'duck_map/handlers/base'
    autoload :InheritableClassAttributes, 'duck_map/attributes'
    autoload :LastMod, 'duck_map/last_mod'
    autoload :List, 'duck_map/list'
    autoload :Logger, 'duck_map/logger'
    autoload :Mapper, 'duck_map/mapper'
    autoload :Model, 'duck_map/model'
    autoload :Route, 'duck_map/route'
    autoload :RouteFilter, 'duck_map/route_filter'
    autoload :RouteSet, 'duck_map/route_set'
    autoload :SitemapControllerHelpers, 'duck_map/controller_helpers'
    autoload :SitemapHelpers, 'duck_map/view_helpers'
    autoload :SitemapObject, 'duck_map/sitemap_object'
    autoload :Static, 'duck_map/static'
    autoload :Sync, 'duck_map/sync'
    autoload :Version, 'duck_map/version'

  end

  class Engine < Rails::Engine

#     # this is so I can develop the gem
#     # run dev.com, make changes to files in lib/duck_captcha, refresh browser.
#     unless Rails.env.to_sym.eql?(:production)
#       auto_path_spec = File.expand_path(File.dirname(__FILE__))
#       config.autoload_paths << auto_path_spec.slice(0, auto_path_spec.rindex("/"))
#     end

    initializer "duck_map" do
      Time::DATE_FORMATS.merge!(meta: "%a, %d %b %Y %H:%M:%S %Z",
                                sitemap: "%Y-%m-%dT%H:%M:%S+00:00",
                                sitemap_locale: "%m/%d/%Y %H:%M:%S",
                                seo: "%a, %d %b %Y %H:%M:%S %Z")
    end

    ActionDispatch::Journey::Route.send :include, Route

    ActionDispatch::Routing::RouteSet.send :include, RouteSet
    ActionDispatch::Routing::RouteSet.send :include, RouteFilter

    ActionDispatch::Routing::Mapper.send :include, ConfigHelpers
    ActionDispatch::Routing::Mapper.send :include, Mapper
    ActionDispatch::Routing::Mapper.send :include, MapperMethods

    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Base.send :include, InheritableClassAttributes
      ActiveRecord::Base.send :include, Attributes
      ActiveRecord::Base.send :include, SitemapObject

    end

    ActiveSupport.on_load(:before_initialize) do
      ActionController::Base.send :include, InheritableClassAttributes
      ActionController::Base.send :include, Attributes
      ActionController::Base.send :include, ControllerHelpers
      ActionController::Base.send :include, Handlers::Base
      ActionController::Base.send :include, Handlers::Edit
      ActionController::Base.send :include, Handlers::New
      ActionController::Base.send :include, Handlers::Index
      ActionController::Base.send :include, Handlers::Show
      ActionController::Base.send :include, Model
      ActionController::Base.send :include, SitemapObject
    end

    ActiveSupport.on_load(:action_view) do
      ActionView::Base.send :include, ActionViewHelpers
    end

  end

  def self.logger
    return Logger.logger
  end

  def self.console(msg)
    logger.console msg
  end

end
