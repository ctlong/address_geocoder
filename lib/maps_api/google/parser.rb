require 'address_geocoder/parser'

module MapsApi
  module Google
    # Class for parsing Google Maps API responses
    class Parser < ::AddressGeocoder::Parser
      # List of Google's attribute title for streets
      STREET_TYPES = { values: %w(route), name: 'street' }.freeze
      # List of Google's attribute title for cities
      CITY_TYPES   = { values: %w(neighborhood locality sublocality),
                       name: 'city' }.freeze
      # List of Google's attribute titles for states
      STATE_TYPES  = { values: %w(administrative_area_level_4
                                  administrative_area_level_3
                                  administrative_area_level_2
                                  administrative_area_level_1),
                       name: 'state' }.freeze
      # List of Google's attribute titles for postal codes
      POSTAL_TYPES = { values: %w(postal_code postal_code_prefix),
                       name: 'postal_code' }.freeze

      # Convert Google Maps' response into our format with the goal of finding
      # several matching addresses
      # @return (see AddressGeocoder::Parser#parse_response)
      def parse_response
        @fields.each do |field|
          parse_field(field)
        end
        @addresses.delete(:switch)
        @addresses = [@addresses].flatten
        @addresses
      end

      # Takes a specific field and converts it into our format
      # @param field [Hash] one particular field from Google Maps' response
      # @return [void]
      def parse_field(field)
        # if similar?(field['types'], CITY_TYPES)
        #   matched_city(field['long_name'])
        # elsif similar?(field['types'], STATE_TYPES)
        #   matched_state(field['long_name'])
        # elsif similar?(field['types'], ['administrative_area_level_1'])
        #   matched_state(field['short_name'])
        # elsif similar?(field['types'], POSTAL_TYPES)
        #   @addresses[:postal_code] = field['long_name']
        # elsif similar?(field['types'], ['route'])
        #   @addresses[:street] = field['long_name']
        # end
        [STREET_TYPES, CITY_TYPES, STATE_TYPES, POSTAL_TYPES].each do |type|
          if similar?(field['types'], type[:values])
            send("add_#{type[:name]}", field)
          end
        end
      end

      # Determine whether a specific value should be present or not in Google
      # Maps' response
      def self.value_present?(level, comparison_array, value)
        comparison_array.include?(level) && value
      end

      def self.just_country?(google_response)
        google_response['results'][0]['address_components'].count == 1
      end

      def self.correct_country?(google_response, country)
        components = google_response['results']
        components = components[0]['address_components']
        (components.select { |x| x['short_name'] == country }).any?
      end

      private

      def similar?(array1, array2)
        (array1 & array2).any?
      end

      def add_street(field)
        @addresses[:street] = field['long_name']
      end

      def add_city(field)
        if @addresses[:city]
          @addresses[:state]  = field['long_name']
          @addresses[:switch] = true
        else
          @addresses[:city] = field['long_name']
        end
      end

      def add_state(field)
        str = if field['types'].include? 'administrative_area_level_1'
                'short_name'
              else
                'long_name'
              end
        if @addresses[:switch]
          @addresses[:city]   = @addresses[:state]
          @addresses[:switch] = false
        end
        @addresses[:state] = field[str]
      end

      def add_postal_code(field)
        @addresses[:postal_code] = field['long_name']
      end
    end
  end
end
