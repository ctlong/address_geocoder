require 'address_geocoder/requester'
require 'maps_api/google/url_generator'
require 'maps_api/google/parser'

module MapsApi
  module Google
    # Class for making requests to Google Maps API
    class Requester < ::AddressGeocoder::Requester
      # The call levels to cycle through when using postal code
      CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3,
                            remove_state: 4 }.freeze
      # The call levels to cycle through when not using postal code
      CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze

      # @!attribute url_generator
      # @return [UrlGenerator] a class instance
      attr_accessor :url_generator

      # Make a call to Google Maps' Geocoding API
      # @return (see AddressGeocoder::Requester#make_call)
      def make_call(address, language, api_key)
        @language = language
        @api_key  = api_key
        @address = address.dup
        address.delete(:street)
        address.delete(:city)  unless valid_city?
        address.delete(:state) unless valid_state?
        @url_generator = UrlGenerator.new(address: address, api_key: @api_key,
                                          language: @language, street: @address[:street])
        call_levels.each do |level_of_search|
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
        return false if Parser.value_present?(level, [3, 4, 7], valid_city?)
        # False if had valid state but level didn't include state
        return false if Parser.value_present?(level, [4], valid_state?)
        # False if had valid postal code but level didn't include postal code
        return false if Parser.value_present?(level, [5, 6, 7], valid_postal_code?)
        # Else true
        true
      end

      private

      def call_levels
        # 1. Init levels
        levels  = []
        # 2. Assign base levels unless no street
        levels += [CYCLEWITHPOSTAL[:all], CYCLEWITHNOPOSTAL[:all]] unless @address[:street].empty?
        # 3. Assign levels that don't use street if valid city
        levels += [CYCLEWITHPOSTAL[:remove_street], CYCLEWITHNOPOSTAL[:remove_street]] if valid_city?
        # 4. Assign levels that don't use street,city if valid state
        levels += [CYCLEWITHPOSTAL[:remove_city], CYCLEWITHNOPOSTAL[:remove_city]] if valid_state?
        # 5. If valid postal code:
        if valid_postal_code?
          # 5.1 Assign the level that doesn't use street,city,state
          levels  += [CYCLEWITHPOSTAL[:remove_state]]
        # 6. Else:
        else
          # 6.1 Remove all levels that included postal code
          levels  -= CYCLEWITHPOSTAL.values
        end
        # 7. Return sorted array
        levels.sort!
      end

      # Determines whether the given city is valid or not
      # @return [Boolean] true, or false if the city name does not pass the Regex
      def valid_city?
        @address[:city] && (@address[:city][REGEX] != '')
      end

      # Determines whether the given state is valid or not
      # @return [Boolean] true, or false if the state name does not pass the Regex
      def valid_state?
        @address[:state] && (@address[:state][REGEX] != '')
      end

      # Determines whether the given postal code is valid or not
      # @return [Boolean] true, or false if the postal code does not pass the
      #   specs
      def valid_postal_code?
        # 1. Remove spaces
        postal_code = @address[:postal_code].to_s.tr(' ', '')
        # 2. False if country does not have postal codes
        return false unless @address[:country][:postal_code]
        # 3. False if postal code length is not at least 4
        return false if postal_code.length < 3
        # 4. False if postal code is all one char (if that char isn't 1-9)
        all_one_char = postal_code.tr(postal_code[0], '') == ''
        return false if all_one_char && !(postal_code[0].to_i.in? Array(1..9))
        true
      end
    end
  end
end
