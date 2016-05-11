require 'address_geocoder/requester'

module MapsApi
  module Google
    # Class for making requests to Google Maps API
    class Requester < ::AddressGeocoder::Requester
      # @!attribute [w] url_generator
      # @return [UrlGenerator] a class instance
      attr_writer :url_generator

      def make_call
        attempts = 0
        @result = HTTParty.get(@url_generator.generate_url)
      rescue
        sleep(0.5)
        attempts += 1
        retry if attempts <= 5
        failure('Could not connect to GoogleAPI')
      end
      # Determines whether the request to Google Maps' Geocoding API was a
      # success
      # @return (see AddressGeocoder::Requester#success?)
      def success?
        return false unless @result['status'] == 'OK'
        return false unless @result['results'][0]['address_components'].length > 1
        true
      end
    end
  end
end
