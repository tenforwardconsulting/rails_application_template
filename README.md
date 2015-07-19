# Ten Forward Rails application template
This template made for Rails 4.2.3

    rails new <project_name> --skip-test-unit --database=postgresql --template=path/to/template.rb

## Generator templates
The files in lib/templates/rails are modified from their [source in the rails repo](https://github.com/rails/rails/tree/master/railties/lib/rails/generators/rails)

## TODO
* See template.rb
* Extract sections into their own self contained generator (and add to jefferies tube)
* Use gsub\_file instead of copy\_file when able? (so changes can be made to the same file from multiple places)
* Add responsive tables javascript

## Testing
First time

    rails new a_test --skip-test-unit --database=postgresql --template=path/to/template.rb

Every time after

    cd a_test && spring stop && cd .. && rm -rf a_test && rails new a_test --skip-test-unit --database=postgresql --template=path/to/template.rb

