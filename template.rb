################################################################################
# By overwriting the source_paths method to contain the location of your template,
# methods like copy_file will accept relative paths to your template's location.
################################################################################
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

################################################################################
# Heroku
################################################################################
if yes?("Deploying to Heroku?")
  gem 'rails_12factor', group: :production
end

################################################################################
# API
################################################################################
if yes?("Create API files?")
  # Put api_constraints in lib
  # ApiController with render_success, render_error, etc methods
  # Puts token on model
  # spec/requests. Probably some basic tests for error handling, authenticating?
  # spec/support/request_helpers
end

################################################################################
# Gems
################################################################################
# TODO We should copy over a gemfile instead since the default one is full of crap
gem 'awesome_print'
gem 'coffee-rails', '~> 4.1.0'
gem 'compass-rails'
gem 'devise'
gem 'figaro'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jefferies_tube', git: 'https://github.com/tenforwardconsulting/jefferies_tube'
gem 'jquery-rails'
gem 'pg'
gem 'premailer-rails'
gem 'rails', '4.2.3'
gem 'sass-rails', '~> 5.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'simple_form'
gem 'uglifier', '>= 1.3.0'
gem 'will_paginate'

gem_group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'web-console', '~> 2.0'
end

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'erb2haml'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'spring'
  gem 'spring-commands-rspec'
end

gem_group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', require: false
end

################################################################################
# RVM
################################################################################
require 'rvm'
latest_ruby_version = ask "What's the latest ruby version?" # RVM::Environment.new.list_known.select { |str| str.include? "[ruby-]" }.last.gsub("[ruby-]", '').gsub(/\[|\]/, '')
file '.ruby-version', latest_ruby_version
file '.ruby-gemset', @app_name

rvm = RVM::Environment.new(latest_ruby_version)

puts "Creating gemset #{@app_name} in #{latest_ruby_version}"
rvm.gemset_create(@app_name)
puts "Now using gemset #{@app_name}"
rvm.gemset_use!(@app_name)

puts "Installing bundler gem."
rvm.system("gem", "install", "bundler") and puts "Successfully installed bundler"

################################################################################
# Initial
################################################################################
run "bundle config build.nokogiri --use-system-libraries"
run "bundle install"
run "spring binstub --all"
rake "db:create"

################################################################################
# RSpec
################################################################################
generate 'rspec:install'

spec_helper = File.read('spec/spec_helper.rb').
  # Uncomment rspec defaults
  gsub("# The settings below are suggested to provide a good initial experience\n", '').
  gsub("# with RSpec, but feel free to customize to your heart's content.\n", '').
  gsub("=begin\n", '').
  gsub("=end\n", '').
  # Comment out profile examples config
  gsub("  config.profile_examples = 10\n", "  #config.profile_examples = 10\n")
file 'spec/spec_helper.rb', spec_helper, force: true

rails_helper = File.read('spec/rails_helper.rb').gsub(
  "#\n# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }\n",
  "Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }\n"
)
file 'spec/rails_helper.rb', rails_helper, force: true

# TODO Copy over spec/support files

################################################################################
# Layout
################################################################################
rake "haml:replace_erbs"
# Customize layouts/application.html.haml
#   Add .content
#   Add notice, alerts

################################################################################
# Stylesheets
################################################################################
# Add stock sass files (layout, variables, forms, etc)

################################################################################
# Javascript
################################################################################
# Add window.ProjectName = {} to application.js

################################################################################
# Email
################################################################################
# Add ApplicationMailer
# Add delayed job
# Add email.sass, emails/_layout.sass
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: :development
environment "config.action_mailer.delivery_method = :letter_opener", env: :development

################################################################################
# HomeController
################################################################################
# Add HomeController
# Add view
route "root to: 'home#index'" # Clear routes and set root to home controller

################################################################################
# Devise
################################################################################
generate "devise:install"
generate "devise:views" and rake "haml:replace_erbs"
# Create DeviseMailer with layout 'mailer'
# Change password length min to 6
# Add devise classes to top of files (.devise-page, .devise-sessions-new, .devise-passwords-edit, etc)
# Add devise stylesheet app/assets/stylesheets/_devise.sass

################################################################################
# Simple form
################################################################################
# I think there's a generator for this

################################################################################
# VCR
################################################################################
# Add vcr cassettes directory to gitignore


################################################################################
# Templates and Generators
################################################################################
# Configure generators (esp. controller and scaffold_controller)
# Add templates for remaining generators

################################################################################
# Capistrano
################################################################################
# Make deploys/production.rb
# Make sure deploy.rb has the defaults we linke (linked_files/dirs, branch setting, ...)
# Add set :passenger_restart_with_touch, true to deploy.rb

################################################################################
# Git
################################################################################
after_bundle do
  git :init
  git add: '.'
  git commit: '-m "Initial commit, Ten Forward rails template"'
end
