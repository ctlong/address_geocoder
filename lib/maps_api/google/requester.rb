require 'address_geocoder/requester'
require 'maps_api/google/url_generator'
require 'maps_api/google/parser'

module MapsApi
  module Google
    # Class for making requests to Google Maps API
    class Requester < ::AddressGeocoder::Requester
      # Include MapsApi methods and variables
      include MapsApi

      # @!attribute url_generator
      # @return [UrlGenerator] a class instance
      attr_accessor :url_generator

      # Make a call to Google Maps' Geocoding API
      # @return (see AddressGeocoder::Requester#make_call)
      def make_call(address, language, api_key)
        @language = language
        @api_key  = api_key
        @address  = address.dup
        address.delete(:street)
        address.delete(:city)  unless valid_city?(@address[:city])
        address.delete(:state) unless valid_state?(@address[:state])
        @url_generator = UrlGenerator.new(address: address, api_key: @api_key,
                                          language: @language, street: @address[:street])
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
        return false if Parser.just_country?(@result)
        # False if country is not inputted country
        return false if !Parser.correct_country?(@result, @address[:country][:alpha2])
        # False if had valid city but level didn't include city
        return false if Parser.value_present?(level, [3, 4, 7], valid_city?(@address[:city]))
        # False if had valid state but level didn't include state
        return false if Parser.value_present?(level, [4], valid_state?(@address[:state]))
        # False if had valid postal code but level didn't include postal code
        return false if Parser.value_present?(level, [5, 6, 7], valid_postal_code?(@address[:postal_code], @address[:country]))
        # Else true
        true
      end
    end
  end
end
