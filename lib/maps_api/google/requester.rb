require 'address_geocoder/requester'

# Namespace for classes and modules that handling API communication
# @since 0.0.1
module MapsApi
  # Namespace for classes that handle Google
  # @since 0.0.1
  module Google
    class Requester < ::AddressGeocoder::Requester
      def initialize(url)
        attempts = 0
        begin
          @result = HTTParty.get(url)
        rescue
          sleep(0.5)
          attempts += 1
          retry if attempts <= 5
          failure('Could not connect to GoogleAPI')
        end
      end

      def success?
        return false unless @result['status'] == 'OK'
        return false unless @result['results'][0]['address_components'].length > 1
        true
      end
    end
  end
end
