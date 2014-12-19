# This file is used by Rack-based servers to start the application.

# require 'rack/reverse_proxy'
# use Rack::ReverseProxy do
#   reverse_proxy '/rpc', 'http://localhost:5680/'
# end

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
