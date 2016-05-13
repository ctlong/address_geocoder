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
      # The call levels to cycle through
      CYCLE = { base: [1, 5], no_street: [2, 6], no_city: [3, 7],
                no_state: [4] }.freeze

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
        params = prune_address.map { |key, value| add(key, value) }
        params = params.join.tr('\=', ':').chop

        if ([1, 5] & [@level]).any?
          street = hash_to_query('address' => @street) + '&'
        end

        params << "&key=#{@api_key}" unless @api_key.empty?

        language = "&language=#{@language}" if LANGUAGES.include? @language

        "#{URL}#{street}components=#{params}#{language}"
      end

      # Generates layers of calls to make, starting with a base layer that calls
      # all valid fields, and removing a layer each call
      # @return [Array<Integer>] a list of calls to determine what values are
      #   used in the call to Google Maps' API
      def levels
        levels  = []
        # Assign base levels unless no street
        levels += CYCLE[:base]      unless @street.empty?
        # Assign levels that don't use street if valid city
        levels += CYCLE[:no_street] if valid_city?(@address[:city])
        # Assign levels that don't use street,city if valid state
        levels += CYCLE[:no_city]   if valid_state?(@address[:state])
        if valid_postal_code?(@address[:postal_code], @address[:country])
          # Assign the level that doesn't use street,city,state
          levels += CYCLE[:no_state]
        else
          # Remove all levels that included postal code
          levels -= [5, 6, 7]
        end
        levels.sort
      end

      private

      # Removes attributes from the address that don't fit with the level
      # @return [Hash] an address object to add to the call
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
