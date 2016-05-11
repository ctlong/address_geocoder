require 'address_geocoder/client'
require 'maps_api/google/parser'
require 'maps_api/google/requester'
require 'maps_api/google/url_generator'

module MapsApi
  module Google
    # Class for interacting with Google Maps API
    class Client < ::AddressGeocoder::Client
      # The call levels to cycle through when using postal code
      CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3,
                            remove_state: 4 }.freeze
      # The call levels to cycle through when not using postal code
      CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze

      # Initiates a call to GoogleMaps' Geocoding API
      # @return (see AddressGeocoder::Client#call)
      def call
        @former_address = { city: @city, street: @street, country: @country,
                            postal_code: @postal_code, state: @state }
        address = @former_address.dup
        address.delete(:street)
        address.delete(:city)  unless valid_city?
        address.delete(:state) unless valid_state?
        @url_generator = UrlGenerator.new(address: address, api_key: @api_key,
                                          language: @language, street: @street)
        call_levels.each do |level_of_search|
          # Set url
          @url_generator.level   = level_of_search
          @url_generator.address = address.dup
          # Make call to google
          @response = Requester.new(@url_generator.generate_url)
          # If the address succeeded:
          if @response.success?
            @response.result['certainty'] = evaluate_certainty(level_of_search)
            break
          end
        end
      end

      # Assigns the entered variables to their proper instance variables
      # @param (see AddressGeocoder::Client#assign_initial)
      # @return (see AddressGeocoder::Client#assign_initial)
      def assign_initial(args)
        @url_generator = UrlGenerator.new
        # @requester     = Requester.new
        # @parser        = Parser.new
        super args
      end

      private

      def evaluate_certainty(level)
        # False if only returned country
        return false if Parser.just_country?(@response)
        # False if country is not inputted country
        return false if !Parser.correct_country?(@response, @country)
        # False if had valid city but level didn't include city
        return false if Parser.value_present?(level, [3, 4, 7], valid_city?)
        # False if had valid state but level didn't include state
        return false if Parser.value_present?(level, [4], valid_state?)
        # False if had valid postal code but level didn't include postal code
        return false if Parser.value_present?(level, [5, 6, 7], valid_postal_code?)
        # Else true
        true
      end

      def call_levels
        # 1. Init levels
        levels  = []
        # 2. Assign base levels unless no street
        levels += [CYCLEWITHPOSTAL[:all], CYCLEWITHNOPOSTAL[:all]] unless @street.empty?
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
    end
  end
end
