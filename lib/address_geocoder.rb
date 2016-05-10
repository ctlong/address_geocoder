require 'yaml'
require 'maps_api'

# Namespace for classes and modules directly relating to the gem
# @since 0.0.1
module AddressGeocoder
  COUNTRIES = YAML.load_file('countries.yaml')
end
