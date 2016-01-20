source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.5'
gem 'bootstrap_form'
gem 'cancancan'
gem 'devise'
gem 'http_logger'
gem 'jquery-rails'
gem 'less-rails'
gem 'nokogiri'
gem 'omniauth-mit-oauth2'
gem 'omniauth-oauth2'
gem 'rest-client'
gem 'rubyzip', require: 'zip'
gem 'skylight'
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :production, :development do
  gem 'passenger'
end

group :development, :test do
  gem 'byebug'
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
  gem 'rubocop'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'coveralls', require: false
  gem 'minitest-reporters'
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'vcr'
  gem 'webmock'
end
