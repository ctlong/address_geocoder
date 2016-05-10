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

      # Google accepted language codes
      LANGUAGES = ['zh-CN', 'ja', 'es', 'ko', 'ru', 'de', 'fr'].freeze

      # Generates a URL with which to call Google Maps' Geocoding API
      # @return (see AddressGeocoder::UrlGenerator#generate_url)
      def generate_url
        prune
        params = @address.map { |key, value| add(key, value) }
        params = params.join
        params.tr!('\=', ':')
        params.chop!

        if ([1, 5] & [@level]).any?
          street = hash_to_query('address' => @street) + '&'
        end
        params << "&key=#{@api_key}" unless @api_key.empty?
        language = if @language && (LANGUAGES.include? @language)
                     "&language=#{@language}"
                   end

        "https://maps.googleapis.com/maps/api/geocode/json?#{street}components=#{params}#{language}"
      end

      private

      # Removes attributes from the address that don't fit with the level
      # @return [void]
      def prune
        @address.delete(:postal_code) if @level > 4
        @address.delete(:city)        if ([3, 4, 7] & [@level]).any?
        @address.delete(:state)       if @level == 4
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
