require 'uri'

class AddressGeocoder
  class Url # :nodoc:
    GOOGLE_TITLES = {
      country: 'country',
      postal_code: 'postal_code',
      city: 'locality',
      state: 'administrative_area'
    }.freeze

    LANGUAGES = {
      CN: 'zh-CN',
      JP: 'ja',
      ES: 'es',
      KP: 'ko',
      RU: 'ru',
      DE: 'de',
      FR: 'fr'
    }.freeze

    def initialize(opts = {})
      @street           = opts[:street]
      @level            = opts[:level]
      @api_key          = opts[:api_key]
      @enable_languages = opts[:enable_languages]
      @address = prune(opts)
    end

    def formulate
      params = ''
      @address.each do |key, value|
        params += '|' unless params.empty?
        params += hash_to_query(GOOGLE_TITLES[key] => value)
      end
      params.tr!('\=', ':')

      street   = hash_to_query('address' => @street) + '&' if ([1, 5] & [@level]).any?
      params  += "&key=#{@api_key}" unless @api_key.empty?
      if @enable_languages && (lang_code = LANGUAGES[@address[:country].to_sym])
        language = "&language=#{lang_code}"
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
      hash.delete(:enable_languages)
      hash.delete(:postal_code) if @level > 4
      hash.delete(:city)        if ([3, 4, 7] & [@level]).any?
      hash.delete(:state)       if @level == 4
      hash
    end
  end
end
