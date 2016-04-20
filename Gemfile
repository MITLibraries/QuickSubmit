source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.6'
gem 'aws-sdk', '~> 2'
gem 'bootstrap_form', git: 'https://github.com/MITLibraries/rails-bootstrap-forms',
                      branch: 'use_parameterize_for_check_box_label_for'
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
gem 'twitter-bootstrap-rails'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :production, :development do
  gem 'puma'
end

group :development, :test do
  gem 'byebug'
  gem 'fakes3'
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
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
