# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
#if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  #ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
#end

require "duck_map_mongoid"
require "hash_model"
require "tableless_model"
require "lastmod_setup"
LastmodSetup.setup
