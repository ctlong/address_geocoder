require 'uri'
require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for generatoring URLs to call maps APIs
  class UrlGenerator
    # @!attribute street
    # @return (see AddressGeocoder::Client#street)
    attr_accessor :street

    # @!attribute level
    # @return [Integer] the level at which to generate the URL
    attr_accessor :level

    # @!attribute api_key
    # @return (see AddressGeocoder::Client#api_key)
    attr_accessor :api_key

    # @!attribute language
    # @return (see AddressGeocoder::Client#language)
    attr_accessor :language

    # @!attribute address
    # @return [Hash]
    attr_accessor :address

    def initialize(opts = {})
      @street   = opts[:street]
      @level    = opts[:level]
      @api_key  = opts[:api_key]
      @language = opts[:language]
      @address  = opts[:address]
    end

    # @abstract Abstract base method for generating a URL with which to call a
    #   maps API
    # @return [String] a URL to use in calling a maps API
    def generate_url
      raise NeedToOveride, 'generate_url'
    end

    private

    def hash_to_query(hash)
      URI.encode_www_form(hash)
    end
  end
end
