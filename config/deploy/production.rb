server 'localhost', port: 2222, user: 'deploy', roles: %w{web app db}

set :branch, ENV['BRANCH'] || 'production'
