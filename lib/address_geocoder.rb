require 'yaml'
require 'maps_api'

module AddressGeocoder
  COUNTRIES = YAML.load_file('countries.yaml')
end
