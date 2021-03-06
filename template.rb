require 'pry'
require_relative 'template_helpers/template_helpers'
extend TemplateHelpers

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
run "RAILS_ENV=test bin/rake db:create"

################################################################################
# Templates and Generators
################################################################################
puts 'Configuring generators'
generate 'simple_form:install'
insert_into_file 'config/application.rb', after: "config.active_record.raise_in_transactional_callbacks = true\n" do
<<-TEXT

    # Custom generator settings
    config.generators do |g|
      g.javascripts false
      g.helper false
      g.jbuilder false
      g.test_framework :rspec, view_specs: false, routing_specs: false, request_specs: false, controller_specs: false
    end
TEXT
end
puts 'Copying over generators and templates'
directory 'lib/templates', force: true
directory 'lib/generators', force: true
# Some sort of feature test generator? CRUD feature spec generator?

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
directory 'spec/support'

################################################################################
# Layout
################################################################################
rake "haml:replace_erbs"
directory 'app/views/layouts', force: true

################################################################################
# Stylesheets
################################################################################
puts 'Adding default sass files (layout, variables, forms, etc)'
remove_file 'app/assets/stylesheets/application.css'
directory 'app/assets/stylesheets'

################################################################################
# Javascript
################################################################################
puts 'Setting up application.js'
# require_self before require_tree
insert_into_file 'app/assets/javascripts/application.js', "//= require_self\n", before: "//= require_tree ."
# Add window.ProjectName = {} to application.js
append_to_file 'app/assets/javascripts/application.js', "\nwindow.#{@app_name.camelize} = {};"
# Remove turbolinks
gsub_file 'app/assets/javascripts/application.js', "//= require turbolinks\n", ''

################################################################################
# Email
################################################################################
puts 'Adding email layout'
copy_file 'app/views/layouts/mailer.html.haml'

puts 'Adding ApplicationMailer'
create_file 'app/mailers/application_mailer.rb', <<-TEXT
class ApplicationMailer < ActionMailer::Base
  default from: 'Devise.mailer_sender'
  layout 'mailer'

  class SubjectPrefixer
    def self.delivering_email(mail)
      mail.subject.prepend '[#{@app_name.titleize}] '
    end
  end
  register_interceptor SubjectPrefixer
end
TEXT

puts 'Adding email config to development.rb'
gsub_file 'config/environments/development.rb', "  # Don't care if the mailer can't send.\n  config.action_mailer.raise_delivery_errors = false\n", ''
insert_into_file 'config/environments/development.rb', before: "\nend" do
<<-TEXT


  # Action mailer settings
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :letter_opener
TEXT
end

puts 'Adding email config to production.rb'
insert_into_file 'config/environments/production.rb', before: "\nend" do
<<-TEXT


  # Action mailer settings
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  #config.action_mailer.asset_host = 'https://change-me.com'
  #config.action_mailer.default_url_options = { host: 'https://change-me.com' }
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => false
  }
TEXT
end

append_to_file 'config/initializers/assets.rb', "Rails.application.config.assets.precompile += %w( email.css )"

# TODO Style emails?

################################################################################
# HomeController
################################################################################
# TODO Add a good controller template and use it to make home controller?
copy_file 'app/controllers/home_controller.rb'
copy_file 'app/views/home/index.html.haml'
copy_file 'config/routes.rb', force: true

################################################################################
# Devise
################################################################################
generate "devise:install"
generate "devise:views"
rake "haml:replace_erbs"

puts 'Creating devise mailer'
copy_file 'app/mailers/devise_mailer.rb'

puts 'Configuring devise'
gsub_file 'config/initializers/devise.rb', "# config.mailer = 'Devise::Mailer'", "config.mailer = 'DeviseMailer'\n  config.parent_mailer = 'ApplicationMailer'"
gsub_file 'config/initializers/devise.rb', "config.password_length = 8..72", "config.password_length = 6..128"
gsub_file 'config/initializers/devise.rb', "config.sign_out_via = :delete", "config.sign_out_via = [:delete, :get]"

puts 'Formatting devise views'
# This css depends on the stylesheets having been copied over.
# Their copying should probably be done here instead so it is self contained
excluded_directories = ['app/views/devise/shared']
Dir['app/views/devise/*'].each do |devise_directory|
  next if excluded_directories.include?(devise_directory)

  Dir["#{devise_directory}/*.haml"].each do |haml_file|
    action = File.basename(haml_file).gsub('.html.haml', '').gsub('_', '-')
    resource = devise_directory.gsub 'app/views/devise/', ''
    css_class = ".devise-page.#{resource}-#{action}"
    indent_file haml_file, by: 1
    prepend_to_file haml_file, "#{css_class}\n"
  end
end

if true # yes? 'Generate devise model?'
  model_name = 'User' # ask('Model name? [default: User]')
  #model_name = model_name.strip.empty? ? 'User' : model_name
  generate "devise #{model_name}"

  puts 'Configuring devise routes'
  snake_case_model_name = model_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  gsub_file 'config/routes.rb', "devise_for :#{snake_case_model_name}s", "devise_for :#{snake_case_model_name}s, path: 'auth'"

  puts 'Setting up user factory'
  copy_file 'spec/factories/users.rb', force: true

  # Add admin to user
  #   # Create migration
  #   copy_file 'app/controllers/application_controller.rb', force: true # Contains require_admin and render_not_authorized
  #   copy_file 'spec/controllers/application_controller_spec.rb'

  if false # yes? 'Create #{model_name} scaffold?'
    # create basic crud pages and stylesheet? This should use controller scaffold
    # Controller should be admin only (and a way to test that: controller tests? integration tests?)
  end
end

################################################################################
# DelayedJob
################################################################################
puts 'Adding delayed job'
generate 'delayed_job:active_record'
rake 'db:migrate'
create_file 'config/initializers/delayed_job.rb' do
<<-TEXT
Rails.application.config.active_job.queue_adapter = :delayed_job
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', "\#{Rails.env}_delayed_job.log"))
TEXT
end

################################################################################
# VCR
################################################################################
# Add vcr cassettes directory to gitignore

################################################################################
# Capistrano
################################################################################
puts 'Capify!'
run 'cap install STAGES=dev,production'
directory 'config/deploy', force: true

puts 'Configuring config/secrets.yml'
copy_file 'config/secrets.yml', force: true

puts 'Creating config/environments/dev.rb'
run 'cp config/environments/production.rb config/environments/dev.rb'
gsub_file 'config/environments/dev.rb', 'config.consider_all_requests_local       = false', 'config.consider_all_requests_local       = true'

puts 'Configuring Capfile'
append_to_file 'Capfile', "\nrequire 'jefferies_tube/capistrano'"
gsub_file 'Capfile', "# require 'capistrano/rails/assets'\n# require 'capistrano/rails/migrations'", "require 'capistrano/rails'"
gsub_file 'Capfile', "# require 'capistrano/passenger'", "require 'capistrano/passenger'"

puts 'Configuring config/deploy.rb'
gsub_file 'config/deploy.rb',
  "# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp",
  "set :branch, ENV['BRANCH'] || 'master'"
gsub_file 'config/deploy.rb',
  "# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')",
  "set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/application.yml')"
gsub_file 'config/deploy.rb',
  "# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')",
  "set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')"
gsub_file 'config/deploy.rb',
  "# set :deploy_to, '/var/www/my_app_name'",
  "set :deploy_to, '/u/apps/#{@app_name}'"
text = <<-TEXT
namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
TEXT
text2 = <<-TEXT
namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      invoke 'delayed_job:restart'
    end
  end

  after 'deploy:publishing', 'deploy:restart'
end
TEXT
gsub_file 'config/deploy.rb', text, text2
directory 'lib/capistrano'

################################################################################
# Migrate
################################################################################
run 'RAILS_ENV=test bin/rake db:migrate'

################################################################################
# Git
################################################################################
run 'cp config/database.yml config/database.yml.example'
copy_file 'config/application.yml.example'
append_to_file '.gitignore', "\nconfig/application.yml\nconfig/database.yml"
after_bundle do
  git :init
  git add: '.'
  git commit: '-m "Initial commit, Ten Forward rails template"'
end
