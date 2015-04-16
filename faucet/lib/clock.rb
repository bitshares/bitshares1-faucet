require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

module Clockwork
  configure do |config|
    config[:logger] = Logger.new('log/clockwork.log')
  end

  every(2.minutes, 'Updating referral codes') { ReferralCodesWorker.perform_async }
end
