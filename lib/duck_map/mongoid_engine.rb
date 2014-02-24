module DuckMap
  extend ActiveSupport::Autoload

  class MongoidEngine < Rails::Engine

    ActiveSupport.on_load(:active_record) do

      Mongoid::Document.send :include, InheritableClassAttributes
      Mongoid::Document.send :include, Attributes
      Mongoid::Document.send :include, SitemapObject

      Model::Supported.models.push(Mongoid::Document)

    end

  end

end
