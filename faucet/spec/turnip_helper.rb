require 'rails_helper'
require 'turnip/capybara'

include Warden::Test::Helpers
Warden.test_mode!

Dir.glob("spec/acceptance/steps/**/*steps.rb") { |f| load f }

RSpec.configure do |config|
  config.include ReferralCodeSteps
end
