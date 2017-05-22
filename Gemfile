source 'https://rubygems.org'
ruby '2.4.1'

gem 'rails', '5.0.2'
gem 'aws-sdk', '~> 2'
gem 'bootstrap_form'
gem 'cancancan'
gem 'delayed_job_active_record'
gem 'devise'
gem 'http_logger'
gem 'jquery-rails'
gem 'jquery-fileupload-rails'
gem 'less-rails'
gem 'nokogiri'
gem 'omniauth-mit-oauth2'
gem 'omniauth-oauth2'
gem 'rollbar'
gem 'rest-client'
gem 'rubyzip', require: 'zip'
gem 'skylight'
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails', '~> 3'
gem 'uglifier'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :production, :development do
  gem 'puma'
end

group :development, :test do
  gem 'byebug'
  gem 'fakes3', '0.2.5'
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
  gem 'rubocop'
  gem 'web-console'
  gem 'yard'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'minitest-reporters'
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
