require 'address_geocoder/url_generator'

module MapsApi
  module Google
    # Class for generatoring URLs to call Google Maps API
    class UrlGenerator < ::AddressGeocoder::UrlGenerator
      GOOGLE_TITLES = {
        country: 'country',
        postal_code: 'postal_code',
        city: 'locality',
        state: 'administrative_area'
      }.freeze

      LANGUAGES = ['zh-CN', 'ja', 'es', 'ko', 'ru', 'de', 'fr'].freeze

      def formulate
        params = ''
        @address.each do |key, value|
          params += '|' unless params.empty?
          params += hash_to_query(GOOGLE_TITLES[key] => value)
        end
        params.tr!('\=', ':')

        street   = hash_to_query('address' => @street) + '&' if ([1, 5] & [@level]).any?
        params  += "&key=#{@api_key}" unless @api_key.empty?
        if @language && ([@language] & LANGUAGES).any?
          language = "&language=#{@language}"
        else
          language = nil
        end

        "https://maps.googleapis.com/maps/api/geocode/json?#{street}components=#{params}#{language}"
      end

      private

      def hash_to_query(hash)
        URI.encode_www_form(hash)
      end

      def prune(hash)
        hash.delete(:level)
        hash.delete(:street)
        hash.delete(:api_key)
        hash.delete(:language)
        hash.delete(:postal_code) if @level > 4
        hash.delete(:city)        if ([3, 4, 7] & [@level]).any?
        hash.delete(:state)       if @level == 4
        hash
      end
    end
  end
end
