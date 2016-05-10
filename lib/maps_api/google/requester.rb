require 'address_geocoder/requester'

module MapsApi
  module Google
    # Class for making requests to Google Maps API
    class Requester < ::AddressGeocoder::Requester
      # Determines whether the request to Google Maps' Geocoding API was a
      # success
      # @return [Boolean] true, or false if the request failed
      def success?
        return false unless @result['status'] == 'OK'
        return false unless @result['results'][0]['address_components'].length > 1
        true
      end
    end
  end
end
