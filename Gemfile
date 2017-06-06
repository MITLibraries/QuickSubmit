source 'https://rubygems.org'
ruby '2.4.1'

gem 'aws-sdk', '~> 2'
gem 'cancancan'
gem 'delayed_job_active_record'
gem 'devise'
gem 'http_logger'
gem 'jquery-fileupload-rails'
gem 'jquery-rails'
gem 'jquery-validation-rails'
gem 'less-rails'
gem 'nokogiri'
gem 'omniauth-mit-oauth2'
gem 'omniauth-oauth2'
gem 'rails', '5.0.3'
gem 'rest-client'
gem 'rollbar'
gem 'rubyzip', require: 'zip'
gem 'simple_form'
gem 'skylight'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :production, :development do
  gem 'puma'
end

group :development, :test do
  gem 'fakes3', '0.2.5'
  gem 'pry-rails'
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
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
