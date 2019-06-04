# Southwest Checkin 2.X

[![Build Status](https://travis-ci.org/davidkassa/southwest-checkin.svg?branch=master)](https://travis-ci.org/davidkassa/southwest-checkin)
[![Coverage Status](https://coveralls.io/repos/github/davidkassa/southwest-checkin/badge.svg?branch=master)](https://coveralls.io/github/davidkassa/southwest-checkin?branch=master)

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Automatically checks in passengers for their Southwest Flight.

Version 2.0 of this project is a complete rewrite of the service. The brittle HTML parsing and form submissions are a thing of the past. A much better approach is being taken to automate checkins. And, importantly, the new version has a robust test suite. It is even written in a new language (Ruby) and framework (Rails).

If you are interested in the old version, see the [1.0 branch](https://github.com/aortbals/southwest-checkin/tree/1.0).

## Features

- Accounts
  - an easy and convient way to manage your reservations
  - view or remove your reservations at any time
  - increased security
- Email Notifications
  - Notified when a reservation is added
  - Notified on successful checkin
- Checks in all passengers for a given confirmation number
- Secured via HTTPS
- Modern UI
- Modern background processing and job scheduling
- Full test suite

## Build

Can run on Heroku with a single button click
Updated for Ruby 2.6.3, Rails 5.2.3 by a non-Rails person

Grab the source for checkin

```
git clone https://github.com/davidkassa/southwest-checkin.git
cd southwest-checkin
```

Install the bundled gems

```
bundle install
```

Create a db user and give them create privileges (ignore any directory errors)
Populate the db

```
rake db:create db:migrate db:seed
```

Create a config file replace your website, email, and email server. It must accept mail on port 587 with tls.
You can use .env.example as a template

```
echo 'SITE_NAME=Southwest Checkin
SITE_URL=http://mywebsite.com
ASSET_HOST=http://mywebsite.com
MAILER_DEFAULT_FROM_EMAIL=email@mywebsite.com
MAILER_DEFAULT_REPLY_TO=email@mywebsite.com
DEPLOY_BRANCH=master
DEPLOY_USER=deploy
DEPLOY_PORT=22
MAILER_ADDRESS=mail.mywebsite.com
MAILER_DOMAIN=mywebsite.com
MAILER_USERNAME=email@mywebsite.com
MAILER_PASSWORD=mypassword
MAILER_DEFAULT_HOST=
DEPLOY_DOMAIN=
DEPLOY_TO=
DEPLOY_REPOSITORY=
DEPLOY_USE_RBENV=true
MAILER_DEFAULT_PROTOCOL=http
MAILER_DEFAULT_HOST=mywebsite.com' > .env
```

## Old but maybe useful bits

Create a script to launch everything

```
echo '#!/bin/sh
service postgresql restart
service redis-server restart
sleep 2
echo Starting rails
tmux new -s rails  -d
tmux send-keys  -t rails "cd /root/southwest-checkin/app" C-m
tmux send-keys  -t rails "/root/.rbenv/shims/rails s -b 0.0.0.0 -p 80 -e development" C-m
tmux new -s sidekiq -d
sleep 2
echo Starting sidekiq
tmux send-keys  -t sidekiq "cd /root/southwest-checkin" C-m
tmux send-keys  -t sidekiq "/root/.rbenv/shims/bundle exec sidekiq &" C-m' > /root/start.sh
```

Enable Email in Dev Mode (update action_mailer settings)
nano config/environments/development.rb

```
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.asset_host = ENV['ASSET_HOST']
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {
    host: ENV['MAILER_DEFAULT_HOST'],
    protocol: ENV['MAILER_DEFAULT_PROTOCOL'] || 'https'
  }
  config.action_mailer.default_options  = {
    from: ENV['MAILER_DEFAULT_FROM_EMAIL'],
    reply_to: ENV['MAILER_DEFAULT_REPLY_TO']
  }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV['MAILER_ADDRESS'],
    user_name:            ENV['MAILER_USERNAME'],
    password:             ENV['MAILER_PASSWORD'],
    port:                 587,
    authentication:       'plain',
    enable_starttls_auto: true }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
```
