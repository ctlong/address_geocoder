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
        @fields['address_components'].each do |field|
          parse_field(field)
        end
        define_address
      end

      # Takes a specific field and converts it into our format
      # @param field [Hash] one particular field from Google Maps' response
      # @return [void]
      def parse_field(field)
        [STREET_TYPES, CITY_TYPES, STATE_TYPES, POSTAL_TYPES].each do |type|
          if similar?(field['types'], type[:values])
            send("add_#{type[:name]}", field)
          end
        end
      end

      # Determine whether a specific value should be present or not in Google
      # Maps' response
      def value_present?(level, comparison_array, value)
        comparison_array.include?(level) && value
      end

      def just_country?(google_response)
        google_response['results'][0]['address_components'].count == 1
      end

      def correct_country?(google_response)
        components = google_response['results']
        components = components[0]['address_components']
        (components.select { |x| x['short_name'] == @country[:alpha2] }).any?
      end

      private

      def define_address
        { country: @country, city: @city, state: @state,
          postal_code: @postal_code, street: @street }
      end

      def similar?(array1, array2)
        (array1 & array2).any?
      end

      def add_street(field)
        @street = field['long_name']
      end

      def add_city(field)
        if @city
          @state  = field['long_name']
          @switch = true
        else
          @city = field['long_name']
        end
      end

      def add_state(field)
        str = if field['types'].include? 'administrative_area_level_1'
                'short_name'
              else
                'long_name'
              end
        if @switch
          @city   = @state
          @switch = false
        end
        @state = field[str]
      end

      def add_postal_code(field)
        @postal_code = field['long_name']
      end
    end
  end
end
