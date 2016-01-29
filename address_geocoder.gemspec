$LOAD_PATH.push(File.expand_path("../lib", __FILE__))
require 'address_geocoder/version'

Gem::Specification.new do |s|
  s.name        = 'address_geocoder'
  s.version     = AddressGeocoder::VERSION
  s.license     = 'MIT'
  s.authors     = ['Carson Long', 'Wing Leung Choi']
  s.email       = ['ctlong.970@gmail.com', 'wingleungchoi@gmail.com']
  s.homepage    = ''
  s.summary     = %q{Address validation and geocoding}
  s.description = %q{Calls and parses Google Geocoding API for address validation and geocoding}
  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency 'httparty', ['= 0.13.7']

  s.add_development_dependency 'rspec', ['= 3.4.0']
  s.add_development_dependency 'pry', ['= 0.10.3']
end
