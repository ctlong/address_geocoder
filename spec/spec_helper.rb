$LOAD_PATH << '../lib'
require 'address_geocoder'
require 'maps_api'
require 'pry'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

# set environment variable from .env
lines = File.read '.env'
lines = lines.split('\n')
lines.each do |line|
  line = line.split(' = ')
  ENV[line[0]] = line[1].gsub!('"', '')
end
