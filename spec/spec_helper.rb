require 'address_geocoder'
require 'pry'
RSpec::Expectations.configuration.warn_about_potential_false_positives = false
RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true
end

# set environment variable form .env
lines = File.read '.env'
lines = lines.split('\n')
lines.each do |line|
  line = line.split(' = ')
  ENV[line[0]] = line[1].gsub!("\"", '')
end
