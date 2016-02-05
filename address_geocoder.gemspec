require File.expand_path('../lib/address_geocoder/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'address_geocoder'
  s.version     = AddressGeocoder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Carson Long', 'Wing Leung Choi']
  s.email       = ['ctlong.970@gmail.com', 'wingleungchoi@gmail.com']
  s.homepage    = 'https://github.com/ctlong/address_geocoder'
  s.summary     = %q(Address validation and geocoding)
  s.description = %q(Calls and parses Google Geocoding API for address validation and geocoding)
  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency 'httparty',  ['~> 0.13.7']

  s.add_development_dependency 'rspec', ['~> 3.4.0']
  s.add_development_dependency 'pry',   ['~> 0.10.3']
end
