require 'capybara-screenshot/rspec'
# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run
