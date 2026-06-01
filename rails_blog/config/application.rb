require_relative "boot"
require "logger"
require "rails/all"

Bundler.require(*Rails.groups)

module RailsBlog
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load_paths << Rails.root.join("extras")
  end
end
