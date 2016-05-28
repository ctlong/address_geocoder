# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'address_geocoder/version'

Gem::Specification.new do |s|
  s.name    = 'address_geocoder'
  s.version = AddressGeocoder::VERSION
  s.authors = ['Carson Long', 'Wing Leung Choi']
  s.email   = ['ctlong.970@gmail.com', 'wingleungchoi@gmail.com']

  s.summary     = 'Address validation and geocoding'
  s.description = 'Calls and parses various maps APIs for accurate address validation and geocoding'
  s.homepage    = 'https://github.com/ctlong/address_geocoder'
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.post_install_message = 'Happy mapping!'

  s.add_dependency 'httparty', '~> 0.13.7'
end
