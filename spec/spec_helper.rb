$LOAD_PATH << '../lib'
require 'address_geocoder'
require 'pry'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

# set environment variable from .env
begin
  lines = File.read '.env'
  lines = lines.split('\n')
  lines.each do |line|
    line = line.split(' = ')
    ENV[line[0]] = line[1].gsub!('"', '')
  end
rescue
  puts 'no .env'
end
