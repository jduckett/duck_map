require 'active_support/concern'

module DuckMap

  ##################################################################################
  # Contains methods for generating the contants of a sitemap.
  module SitemapHelpers
    extend ActiveSupport::Concern

    ##################################################################################
    # View helper method to generate the content of a sitemap.  Loops through all of the current
    # Hashes contained in {DuckMap::Model#sitemap_model}.
    # @param [Block] A block to execute for each row contained in {DuckMap::Model#sitemap_model}.
    #
    #
    # To see it in action, have a look at the file.
    #
    # /app/views/sitemap/default_template.xml.erb
    #
    # @return [NilClass]
    def sitemap_content(&block)

      if defined?(self.sitemap_model) && self.sitemap_model.kind_of?(Array)

        self.sitemap_model.each do |row|
          block.call(row)
        end

      end

      return nil
    end

  end

  ##################################################################################
  # Support for seo related meta tags in page headers.
  module ActionViewHelpers
    extend ActiveSupport::Concern

    ##################################################################################
    # Generates a title tag for use inside HTML header area.
    # @return [String] HTML safe title tag.
    def sitemap_meta_title
      return controller.sitemap_meta_data[:title].blank? ? nil : content_tag(:title, controller.sitemap_meta_data[:title], false)
    end

    def sitemap_meta_title=(value)
      controller.sitemap_meta_data[:title] = value
    end

    ##################################################################################
    # Generates a keywords meta tag for use inside HTML header area.
    # @return [String] HTML safe keywords meta tag.
    def sitemap_meta_keywords
      return controller.sitemap_meta_data[:keywords].blank? ? nil : tag(:meta, {name: :keywords, content: controller.sitemap_meta_data[:keywords]}, false, false)
    end

    def sitemap_meta_keywords=(value)
      controller.sitemap_meta_data[:keywords] = value
    end

    ##################################################################################
    # Generates a description meta tag for use inside HTML header area.
    # @return [String] HTML safe description meta tag.
    def sitemap_meta_description
      return controller.sitemap_meta_data[:description].blank? ? nil : tag(:meta, {name: :description, content: controller.sitemap_meta_data[:description]}, false, false)
    end

    def sitemap_meta_description=(value)
      controller.sitemap_meta_data[:description] = value
    end

    ##################################################################################
    # Generates a Last-Modified meta tag for use inside HTML header area.
    # @return [String] HTML safe Last-Modified meta tag.
    def sitemap_meta_lastmod
      return controller.sitemap_meta_data[:lastmod].blank? ? nil : tag(:meta, {name: "Last-Modified", content: controller.sitemap_meta_data[:lastmod]}, false, false)
    end

    def sitemap_meta_lastmod=(value)
      controller.sitemap_meta_data[:lastmod] = value
    end

    ##################################################################################
    # Generates a canonical link tag for use inside HTML header area.
    # @return [String] HTML safe canonical link tag.
    def sitemap_meta_canonical
      return controller.sitemap_meta_data[:canonical].blank? ? nil : tag(:link, {rel: :canonical, href: controller.sitemap_meta_data[:canonical]}, false, false)
    end

    def sitemap_meta_canonical=(value)
      controller.sitemap_meta_data[:canonical] = value
    end

    ##################################################################################
    # Generates a meta tags title, keywords, description and Last-Modified for use inside HTML header area.
    # @return [String] HTML safe title tag.
    def sitemap_meta_tag
      buffer = "#{self.sitemap_meta_title}\r\n    #{self.sitemap_meta_keywords}\r\n    #{self.sitemap_meta_description}\r\n    #{self.sitemap_meta_lastmod}\r\n    #{self.sitemap_meta_canonical}\r\n".html_safe
      return buffer.html_safe
    end

  end

end
