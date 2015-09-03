ENV["RAILS_ENV"] ||= 'test'

require 'engine_cart'
#require 'coveralls'
#Coveralls.wear!('rails')
EngineCart.load_application!

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
  options = {}

  options[:timeout] = 120 if RUBY_PLATFORM == "java"

  Capybara::Poltergeist::Driver.new(app, options)
end

if ENV["COVERAGE"] or ENV["CI"]
  require 'simplecov'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'commonwealth-vlr-engine'

require 'rspec/rails'
require 'capybara/rspec'


RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.infer_spec_type_from_file_location!
end