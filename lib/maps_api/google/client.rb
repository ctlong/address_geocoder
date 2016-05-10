require 'address_geocoder/client'
require 'maps_api/google/parser'

# Namespace for classes and modules that handling API communication
# @since 0.0.1
module MapsApi
  # Namespace for classes that handle Google
  # @since 0.0.1
  module Google
    # Namespace for classes that handle Google
    class Client < ::AddressGeocoder::Client
      CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3, remove_state: 4 }.freeze
      CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze

      # Calls GoogleMaps' Geocoding API
      # @return [void]
      def call
        # 1 initialize former address
        @former_address = { city: @city, street: @street, country: @country, postal_code: @postal_code, state: @state }
        # 2 Loop through the levels (once one works break the loop)
        call_levels.each do |level_of_search|
          # 2.1 Set url
          request_hash = @former_address.merge(level: level_of_search, api_key: @api_key, language: @language)
          request_hash.delete(:city) unless valid_city?
          request_hash.delete(:state) unless valid_state?
          request_url = MapsApi::Url.new(request_hash)
          # 2.2 Make call to google
          @response = MapsApi::Request.new(request_url.formulate)
          # 2.3 If the address succeeded:
          if @response.success?
            @response.result['certainty'] = evaluate_certainty(level_of_search)
            break
          end
        end
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
