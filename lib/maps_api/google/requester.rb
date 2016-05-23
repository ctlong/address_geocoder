require 'address_geocoder/requester'
require 'maps_api/google/url_generator'
require 'maps_api/google/parser'

module MapsApi
  module Google
    # Class for making requests to Google Maps API
    class Requester < ::AddressGeocoder::Requester
      # Make a call to Google Maps' Geocoding API
      # @return (see AddressGeocoder::Requester#make_call)
      def make_call
        @url_generator = UrlGenerator.new(address: @address.dup,
                                          api_key: @api_key,
                                          language: @language)
        @url_generator.levels.each do |level_of_search|
          @url_generator.level = level_of_search
          call
          break if success?
        end
      end

      # Determines whether the request to Google Maps' Geocoding API was a
      # success
      # @return (see AddressGeocoder::Requester#success?)
      def success?
        return false unless @result['status'] == 'OK'
        return false unless @result['results'][0]['address_components'].length > 1
        true
      end

      # Check if the certainty level of the response
      # @note certainty is determined in two ways: first, by ensuring that the
      #   country was not the only field returned and that it was the correct
      #   country; second, that the city, state, and postal code were all
      #   present in the response if they were included in the level of call.
      def certain?
        level = @url_generator.level
        if @parser.just_country?(@result) ||
           @parser.not_correct_country?(@result)
          false
        elsif @parser.city_present?(level) || @parser.state_present?(level) ||
              @parser.pc_present?(level)
          false
        else
          true
        end
      end

      # Return a compacted, flattened array of different address responses.
      # @return (see AddressGeocoder::Requester#array_result)
      def array_result
        [@result['results']].flatten
      end

      private

      def call
        attempts = 0
        begin
          @result = HTTParty.get(@url_generator.generate_url)
        rescue
          sleep(0.5)
          attempts += 1
          retry if attempts <= 5
          connection_error('Could not connect to GoogleAPI')
        end
      end
    end
  end
end
