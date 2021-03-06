require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/jobs/application_job.rb'
  add_filter '/app/mailers/application_mailer.rb'
  add_filter '/app/channels/application_cable/channel.rb'
  add_filter '/app/channels/application_cable/connection.rb'
  add_filter '/app/helpers/'
end

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"  # for Colorized output
require 'vcr'
require 'webmock/minitest'


VCR.configure do |config|
  config.cassette_library_dir = 'test/cassettes' # folder where casettes will be located
  config.hook_into :webmock # tie into this other tool called webmock
  config.default_cassette_options = {
    :record => :new_episodes,    # record new data when we don't have it yet
    :match_requests_on => [:method, :uri, :body] # The http method, URI and body of a request all need to match
  }
  # Don't leave our Slack token lying around in a cassette file.
  config.filter_sensitive_data("<APP_KEY>") do
    ENV['APP_KEY']
  end
  config.filter_sensitive_data("<APP_ID>") do
    ENV['APP_ID']
  end
end

#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

# https://github.com/rails/rails/issues/31324
if ActionPack::VERSION::STRING >= "5.2.0"
  Minitest::Rails::TestUnit = Rails::TestUnit
end

OmniAuth.config.test_mode = true

def mock_auth_hash(user)
  return {
    provider: user.provider,
    uid: user.uid,
    "info" => {
      "email" => user.email,
      "name" => user.name
    }
  }
end

def login(user)
  # Tell OmniAuth to use this user's info when it sees
  # an auth callback from github
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(mock_auth_hash(user))

  # Send a login request for that user
  # Note that we're using the named path for the callback, as defined
  # in the `as:` clause in `config/routes.rb`
  get auth_callback_path(:google_oauth2)

  # In our books app, logging in should always redirect
end


# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...
end
