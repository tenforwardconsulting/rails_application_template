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
#if yes?("Deploying to Heroku?")
  #gem 'rails_12factor', group: :production
#end

################################################################################
# API
################################################################################
#if yes?("Create API files?")
  # Put api_constraints in lib
  # ApiController with render_success, render_error, etc methods
  # Puts token on model
  # spec/requests. Probably some basic tests for error handling, authenticating?
  # spec/support/request_helpers
#end

################################################################################
# Gemfile
################################################################################
copy_file 'Gemfile', force: true

################################################################################
# RVM
################################################################################
require 'rvm'
latest_ruby_version = '2.2.2' # ask "What's the latest ruby version?" # RVM::Environment.new.list_known.select { |str| str.include? "[ruby-]" }.last.gsub("[ruby-]", '').gsub(/\[|\]/, '')
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

puts 'Setting up spec_helper.rb'
spec_helper = File.read('spec/spec_helper.rb').
  # Uncomment rspec defaults
  gsub("# The settings below are suggested to provide a good initial experience\n", '').
  gsub("# with RSpec, but feel free to customize to your heart's content.\n", '').
  gsub("=begin\n", '').
  gsub("=end\n", '').
  # Comment out profile examples config
  gsub("config.profile_examples = 10", "#config.profile_examples = 10")
file 'spec/spec_helper.rb', spec_helper, force: true

puts 'Setting up rails_helper...'
rails_helper = File.read('spec/rails_helper.rb').gsub(
  # Require all files in spec/support
  "#\n# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }",
  "Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }"
).gsub(
  # We use database cleaner to manage the test database
  "config.use_transactional_fixtures = true",
  "# This is set to false in spec/support/database_cleaner.rb\n#config.use_transactional_fixtures = true",
)
file 'spec/rails_helper.rb', rails_helper, force: true

puts 'Copying over spec/support files'
Dir["#{source_paths.first}/spec/support/**/*.rb"].each.map { |file|
  ".#{file.gsub("#{source_paths.first}", '')}"
}.each &method(:copy_file)

################################################################################
# Layout
################################################################################
rake "haml:replace_erbs"
puts "Setting up application.html.haml"
# Add meta viewport tag so responsive works
gsub_file 'app/views/layouts/application.html.haml', '%head', "%head\n    %meta{content: \"width=device-width, initial-scale=1\", name: \"viewport\"}"
# Remove turbolinks
gsub_file 'app/views/layouts/application.html.haml', "    = stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true\n", ''
gsub_file 'app/views/layouts/application.html.haml', "    = javascript_include_tag 'application', 'data-turbolinks-track' => true\n", ''
# Add notice, alert, and wrap yield in main
gsub_file 'app/views/layouts/application.html.haml', '    = yield', <<-TEXT
    - if notice
      .notice= notice
    - if alert
      .alert= alert

    %main= yield
TEXT

################################################################################
# Stylesheets
################################################################################
puts 'Adding default sass files (layout, variables, forms, etc)'
remove_file 'app/assets/stylesheets/application.css'
Dir["#{source_paths.first}/app/assets/stylesheets/**/*.sass"].each.map { |file|
  ".#{file.gsub("#{source_paths.first}", '')}"
}.each &method(:copy_file)

################################################################################
# Javascript
################################################################################
# Add window.ProjectName = {} to application.js

################################################################################
# Email
################################################################################
puts 'Adding email layout'
copy_file './app/views/layouts/mailer.html.haml'
# Add ApplicationMailer
# Add delayed job
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: :development
environment "config.action_mailer.delivery_method = :letter_opener", env: :development

################################################################################
# HomeController
################################################################################
# Add HomeController
# Add view
route "root to: 'home#index'" # Clear routes and set root to home controller todo copy over file instead

################################################################################
# ApplicationController
################################################################################
# Add admin_required filter and render_not_authorized

################################################################################
# Devise
################################################################################
generate "devise:install"
generate "devise:views" and rake "haml:replace_erbs"
# Create DeviseMailer with layout 'mailer'
# Change password length min to 6
# Add devise classes to top of files (.devise-page, .devise-sessions-new, .devise-passwords-edit, etc)
# Add devise stylesheet app/assets/stylesheets/_devise.sass
# Change devise :users path to 'auth' in config/routes.rb
# Ask to create model (default is User)
#   If yes, create basic crud pages, stylesheets etc. This might need to go after
#   templates section

################################################################################
# Simple form
################################################################################
# I think there's a generator for this that makes a template that might need some editing

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
