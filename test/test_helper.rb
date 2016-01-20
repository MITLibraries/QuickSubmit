require 'simplecov'
require 'coveralls'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start('rails')
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails/capybara'
require 'minitest/reporters'
require 'capybara/poltergeist'
require 'database_cleaner'
Minitest::Reporters.use!

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alpha order.
    self.use_transactional_fixtures = false
    fixtures :all

    def mock_auth(user)
      OmniAuth.config.mock_auth[:mit_oauth2] =
        OmniAuth::AuthHash.new(provider: 'mit_oauth2',
                               uid: user.uid,
                               info: { email: user.email })
      visit '/users/auth/mit_oauth2/callback'
    end

    def auth_setup
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
      Rails.application.env_config['omniauth.auth'] =
        OmniAuth.config.mock_auth[:mit_oauth2]
      OmniAuth.config.test_mode = true
    end

    def auth_teardown
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:mit_oauth2] = nil
      reset_session!
    end
  end
end

module ActionController
  class TestCase
    include Devise::TestHelpers
  end
end

DatabaseCleaner.strategy = :transaction

module Minitest
  class Spec
    before :each do
      DatabaseCleaner.start
    end

    after :each do
      DatabaseCleaner.clean
    end
  end
end
