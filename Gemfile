ruby '2.6.3'
source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.3'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1.1'
gem "autoprefixer-rails"
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~>5.2.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.9.1'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.0.0', group: :doc

gem 'typhoeus', '~> 1.3.1' # HTTP request client

gem 'devise', '~> 4.6.2' # Authentication

gem 'sidekiq', '~> 5.2.7' # Background job processing queue
gem 'sinatra', :require => nil # Required for sidekiq web UI
gem 'sidekiq-failures' # Track sidekiq failures

gem 'roadie-rails', '~> 2.1' # Inline styles for emails

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# gem "bcrypt-ruby", :require => "bcrypt"
# gem 'bcrypt', platforms: :ruby

# Use Puma as the app server
gem 'puma'

# Use Mina for deployment
gem 'mina'
gem 'mina-puma', :require => false
gem 'mina-sidekiq', :require => false
gem 'mina-scp', :require => false
gem 'mina-newrelic', :require => false

gem 'dotenv-rails'

# Skylight for performance monitoring
gem 'skylight'

# New Relic application monitoring
gem 'newrelic_rpm'

# Pagination
gem 'kaminari'

# syslog logging with lograge
# gem 'syslogger', '~> 1.6.0'
# gem 'lograge', '~> 0.3.1'

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'rails-controller-testing'
  gem 'awesome_print'
  gem 'vcr', '~> 5.0'

  gem 'letter_opener'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'
  

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'webmock'
  gem 'shoulda-matchers', require: false
  gem 'timecop'
  gem 'coveralls', require: false
  gem 'json-schema-rspec'
end

group :developement do
  gem 'guard'
  gem 'guard-rspec'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7'
end

gem "tzinfo-data", "~> 1.2019"
