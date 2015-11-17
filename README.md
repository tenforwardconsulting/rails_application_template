# DEPRECATED.
Use [sagacious\_succotash](https://github.com/tenforwardconsulting/sagacious_succotash)

# Ten Forward Rails application template
This template made for Rails 4.2.3

This command assumes you are running `rails new` in the same directory that you cloned this repo.

    rails new <project_name> --skip-test-unit --database=postgresql --template=./rails_application_template/template.rb

## Generator templates
The files in lib/templates/rails are modified from their [source in the rails repo](https://github.com/rails/rails/tree/master/railties/lib/rails/generators/rails)

## TODO
* See template.rb
* Extract sections into their own self contained generator (and add to jefferies tube)
* Use gsub\_file instead of copy\_file when able? (so changes can be made to the same file from multiple places)
* Add responsive tables javascript
* Add admin flag to user

## Testing
First time

    rails new a_test --skip-test-unit --database=postgresql --template=path/to/template.rb

Every time after

    cd a_test && spring stop && cd .. && rm -rf a_test && rails new a_test --skip-test-unit --database=postgresql --template=path/to/template.rb

