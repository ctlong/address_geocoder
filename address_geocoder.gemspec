Gem::Specification.new do |s|
  s.name        = "address_geocoder"
  s.version     = "1.0.0"
  s.summary     = "Calls and parses Google Geocoding API for address validation and geocoding"
  s.license     = "MIT"
  s.description = ""
  s.authors     = ["Carson Long", "Wing Leung Choi"]
  s.email       = ["ctlong.970@gmail.com", "wingleungchoi@gmail.com"]
  s.homepage    = ""
  s.files       = ["lib/address_geocoder.rb", "lib/address_geocoder/countries.yaml"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'httparty'
  s.add_development_dependency 'pry'
end