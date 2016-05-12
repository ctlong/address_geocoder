require 'address_geocoder/url_generator'

module MapsApi
  module Google
    # Class for generatoring URLs to call Google Maps API
    class UrlGenerator < ::AddressGeocoder::UrlGenerator
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
