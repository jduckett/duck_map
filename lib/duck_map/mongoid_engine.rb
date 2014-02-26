module DuckMap
  extend ActiveSupport::Autoload

  class MongoidEngine < Rails::Engine

    Mongoid::Document.send :include, InheritableClassAttributes
    Mongoid::Document.send :include, Attributes
    Mongoid::Document.send :include, SitemapObject

    Model::Supported.models.push(Mongoid::Document)

  end

end
