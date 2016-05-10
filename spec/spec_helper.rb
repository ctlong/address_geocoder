require 'address_geocoder'
require 'pry'

require 'simplecov'
SimpleCov.profiles.define 'gem' do
  add_filter '/test/'
  add_filter '/features/'
  add_filter '/spec/'
  add_filter '/autotest/'

  add_group 'Binaries', '/bin/'
  add_group 'Libraries', '/lib/'
  add_group 'Extensions', '/ext/'
  add_group 'Vendor Libraries', '/vendor/'
end
SimpleCov.start 'gem'

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
  ENV[line[0]] = line[1].gsub!('"', '')
end
