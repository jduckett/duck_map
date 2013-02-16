require 'test_helper'

class HashModelTest < ActiveSupport::TestCase

  test "hash model integrity check" do
    model = {default: {title: :default_title,
                        keywords: :default_keywords,
                        description: :default_description,
                        lastmod: :default_updated_at,
                        changefreq: nil,
                        priority: nil,
                        canonical: nil,
                        canonical_host: nil,
                        canonical_port: nil,
                        static_host: nil,
                        static_port: nil,
                        url_format: nil,
                        url_limit: nil,
                        handler: {action_name: :sitemap_index,
                                  first_model: false},
                        segments: {}},
               index: {title: :index_title,
                        keywords: nil,
                        description: :index_description,
                        lastmod: nil,
                        changefreq: :index_changefreq,
                        priority: nil,
                        canonical: :index_canonical,
                        canonical_host: nil,
                        canonical_port: nil,
                        static_host: "index_static_host",
                        static_port: nil,
                        url_format: nil,
                        url_limit: nil,
                        handler: {action_name: :sitemap_show,
                                  first_model: true},
                        segments: {id: :my_id, title: :index_title}}}

    assert HashModel.verify("unit/hash_model", model)
    assert HashModel.verify("unit/hash_model", model[:default], :default)
    assert HashModel.verify("unit/hash_model", model[:index], :index)
  end

end
