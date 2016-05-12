require 'address_geocoder/url_generator'

module MapsApi
  module Google
    # Class for generatoring URLs to call Google Maps API
    class UrlGenerator < ::AddressGeocoder::UrlGenerator
      # Include MapsApi methods and variables
      include MapsApi

      # Google's attribute names for our address variables
      GOOGLE_TITLES = {
        country: 'country',
        postal_code: 'postal_code',
        city: 'locality',
        state: 'administrative_area'
      }.freeze
      # The URL of Google Maps' Geocoding API
      URL = 'https://maps.googleapis.com/maps/api/geocode/json?'.freeze
      # Google accepted language codes
      # @see https://developers.google.com/maps/faq#languagesupport
      LANGUAGES = ['zh-CN', 'ja', 'es', 'ko', 'ru', 'de', 'fr'].freeze
      # The call levels to cycle through when using postal code
      CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3,
                            remove_state: 4 }.freeze
      # The call levels to cycle through when not using postal code
      CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze

      # @!attribute level
      # @return [Integer] the level at which to generate the URL
      attr_accessor :level

      def initialize(args = {})
        @level = args[:level]
        super args
      end

      # Generates a URL with which to call Google Maps' Geocoding API
      # @return (see AddressGeocoder::UrlGenerator#generate_url)
      def generate_url
        address = prune_address
        params  = address.map { |key, value| add(key, value) }
        params  = params.join.tr('\=', ':').chop

        if ([1, 5] & [@level]).any?
          street = hash_to_query('address' => @street) + '&'
        end

        params << "&key=#{@api_key}" unless @api_key.empty?

        language = "&language=#{@language}" if LANGUAGES.include? @language

        "#{URL}#{street}components=#{params}#{language}"
      end

      def levels
        # 1. Init levels
        levels  = []
        # 2. Assign base levels unless no street
        levels += [CYCLEWITHPOSTAL[:all], CYCLEWITHNOPOSTAL[:all]] unless @street.empty?
        # 3. Assign levels that don't use street if valid city
        levels += [CYCLEWITHPOSTAL[:remove_street], CYCLEWITHNOPOSTAL[:remove_street]] if valid_city?(@address[:city])
        # 4. Assign levels that don't use street,city if valid state
        levels += [CYCLEWITHPOSTAL[:remove_city], CYCLEWITHNOPOSTAL[:remove_city]] if valid_state?(@address[:state])
        # 5. If valid postal code:
        if valid_postal_code?(@address[:postal_code], @address[:country])
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

      private

      # Removes attributes from the address that don't fit with the level
      # @return [void]
      def prune_address
        address           = @address.dup
        address[:country] = address[:country][:alpha2]

        address.delete(:postal_code) if @level > 4
        address.delete(:city)        if ([3, 4, 7] & [@level]).any?
        address.delete(:state)       if @level == 4
        address
      end

      # Parses a key and value from a hash into a query
      # @return [String] a query to be used in the URL
      def add(key, value)
        str = hash_to_query(GOOGLE_TITLES[key] => value)
        "#{str}|"
      end
    end
  end
end
