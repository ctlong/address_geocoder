# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'address_geocoder/version'

Gem::Specification.new do |s|
  s.name        = 'address_geocoder'
  s.version     = AddressGeocoder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Carson Long', 'Wing Leung Choi']
  s.email       = ['ctlong.970@gmail.com', 'wingleungchoi@gmail.com']
  s.homepage    = 'https://github.com/ctlong/address_geocoder'
  s.summary     = 'Address validation and geocoding'
  s.description = 'Calls and parses Google Geocoding API for address validation and geocoding'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split("\n")

  s.add_dependency 'httparty', ['~> 0.13.7']
end
