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
          # Make call to google
          attempts = 0
          begin
            @result = HTTParty.get(@url_generator.generate_url)
          rescue
            sleep(0.5)
            attempts += 1
            retry if attempts <= 5
            connection_error('Could not connect to GoogleAPI')
          end
          # If the address succeeded:
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

      def certain?
        level = @url_generator.level
        # False if only returned country
        return false if @parser.just_country?(@result)
        # False if country is not inputted country
        return false if !@parser.correct_country?(@result)
        # False if had valid city but level didn't include city
        return false if @parser.value_present?(level, [3, 4, 7], @address[:city])
        # False if had valid state but level didn't include state
        return false if @parser.value_present?(level, [4], @address[:state])
        # False if had valid postal code but level didn't include postal code
        return false if @parser.value_present?(level, [5, 6, 7], @address[:postal_code])
        # Else true
        true
      end

      def array_result
        [@result['results']].flatten
      end
    end
  end
end
