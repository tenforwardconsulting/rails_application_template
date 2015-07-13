require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 99999, :inspector => true)
end

Capybara.javascript_driver = :poltergeist
