require 'address_geocoder/requester'

# Namespace for classes and modules that handling API communication
# @since 0.0.1
module MapsApi
  # Namespace for classes that handle Google
  # @since 0.0.1
  module Google
    class Requester < ::AddressGeocoder::Requester
      def success?
        return false unless @result['status'] == 'OK'
        return false unless @result['results'][0]['address_components'].length > 1
        true
      end
    end
  end
end
