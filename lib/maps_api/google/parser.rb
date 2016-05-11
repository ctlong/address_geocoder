require 'address_geocoder/parser'

module MapsApi
  module Google
    # Class for parsing Google Maps API responses
    class Parser < ::AddressGeocoder::Parser
      # List of Google's attribute title for cities
      CITY_TYPES   = %w(neighborhood locality sublocality).freeze
      # List of Google's attribute titles for states
      STATE_TYPES  = %w(administrative_area_level_4 administrative_area_level_3 administrative_area_level_2).freeze
      # List of Google's attribute titles for postal codes
      POSTAL_TYPES = %w(postal_code postal_code_prefix).freeze

      # Convert Google Maps' response into our format with the goal of finding
      # several matching addresses
      # @return (see AddressGeocoder::Client#suggested_addresses)
      def parse_google_response
        @fields.each { |field| parse_field(field) }
        @addresses.delete(:switch)
        @addresses
      end

      # Takes a specific field and converts it into our format
      # @param field [Hash] one particular field from Google Maps' response
      # @return [void]
      def parse_field(field)
        @field = field
        if contains?(CITY_TYPES)
          matched_city(field['long_name'])
        elsif contains?(STATE_TYPES)
          matched_state(field['long_name'])
        elsif contains?(['administrative_area_level_1'])
          matched_state(field['short_name'])
        elsif contains?(POSTAL_TYPES)
          @addresses[:postal_code] = field['long_name']
        elsif contains?(['route'])
          @addresses[:street] = field['long_name']
        end
      end

      # Determine whether a specific value should be present or not in Google
      # Maps' response
      def self.value_present?(level, comparison_array, value)
        # comparison_array.include?(level) && value
        ([level] & comparison_array).any? && value
      end

      def self.just_country?(google_response)
        google_response.result['results'][0]['address_components'].count == 1
      end

      def self.correct_country?(google_response, country)
        components = google_response.result['results']
        components = components[0]['address_components']
        (components.select { |x| x['short_name'] == country }).any?
      end

      private

      def contains?(array)
        (@field['types'] & array).any?
      end

      def matched_city(value)
        if @addresses[:city]
          @addresses[:state]  = value
          @addresses[:switch] = true
        else
          @addresses[:city] = value
        end
      end

      def matched_state(value)
        if switched?
          @addresses[:city]   = @addresses[:state]
          @addresses[:switch] = false
        end
        @addresses[:state] = value
      end

      def switched?
        @addresses[:switch]
      end
    end
  end
end
