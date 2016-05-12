require 'yaml'
require 'maps_api/google'

# Namespace for classes and modules that handling API communication
# @since 0.0.1
module MapsApi
  # The regex used to check the state and city for validity
  REGEX = /\A[a-zA-Z\ ]*\z/

  # Determines whether the given city is valid or not
  # @return [Boolean] true, or false if the city name does not pass the Regex
  def valid_city?(city)
    city && (city[REGEX] != '')
  end

  # Determines whether the given state is valid or not
  # @return [Boolean] true, or false if the state name does not pass the Regex
  def valid_state?(state)
    state && (state[REGEX] != '')
  end

  # Determines whether the given postal code is valid or not
  # @return [Boolean] true, or false if the postal code does not pass the
  #   specs
  def valid_postal_code?(postal_code, country)
    # 1. Remove spaces
    pc = postal_code.to_s.tr(' ', '')
    # 2. False if country does not have postal codes
    return false unless country[:postal_code]
    # 3. False if postal code length is not at least 4
    return false if pc.length < 3
    # 4. False if postal code is all one char (if that char isn't 1-9)
    all_one_char = pc.tr(pc[0], '') == ''
    return false if all_one_char && !(pc[0].to_i.in? Array(1..9))
    true
  end
end
