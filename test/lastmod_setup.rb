class LastmodSetup

  SITEMAP_LOCALE =  {sitemap:
                      {books:
                        {edit:  "08/04/2010 02:08:10",
                        index:  "06/08/2012 04:06:12",
                        new:    "04/12/2014 06:04:14",
                        show:   "02/16/2016 08:02:16"},
                      home:
                        {index: "10/26/2004 04:08:16"}
                      }
                    }

  def self.setup

    unless defined?(@@setup_complete)

      File.open(File.join(Rails.root, "config", "locales", "sitemap.yml"), "w") do |f|
        f.write YAML.dump(SITEMAP_LOCALE)
      end

      @@setup_complete = true

    end

  end

end
