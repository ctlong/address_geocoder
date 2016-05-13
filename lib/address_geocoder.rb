require 'yaml'
require 'maps_api'

# Namespace for classes and modules directly relating to the gem
# @since 0.0.1
module AddressGeocoder
  # The collection of countries supported by this gem
  COUNTRIES = YAML.load_file('countries.yaml')
  # The regex used to check the state and city for validity
  REGEX = /\A[a-zA-Z\ ]*\z/
end
