ENV["RAILS_ENV"] = "test"
$:.unshift File.dirname(__FILE__)

require "dev.com/config/environment"
require "rails/test_help"

# this makes "rake test" possible from the gem root directory
require "duck_map"
require "hash_model"
require "tableless_model"
require "lastmod_setup"
LastmodSetup.setup

#require "orm/#{DEVISE_ORM}"

#I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__)

#require 'mocha'
#require 'webrat'
#Webrat.configure do |config|
  #config.mode = :rails
  #config.open_error_files = false
#end

# Add support to load paths so we can overwrite broken webrat setup
#$:.unshift File.expand_path('../support', __FILE__)
#Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# For generators
#require "rails/generators/test_case"
#require "generators/devise/install_generator"
#require "generators/devise/views_generator"

