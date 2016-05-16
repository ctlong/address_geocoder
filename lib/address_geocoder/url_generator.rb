require 'uri'
require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for generatoring URLs to call maps APIs
  # @todo If not other apis need this class then maybe this should be a map api
  #   specific class (ie. might not need an abstract base class).
  class UrlGenerator
    # @!attribute api_key
    # @return (see AddressGeocoder::Client#api_key)
    attr_accessor :api_key

    # @!attribute language
    # @return (see AddressGeocoder::Client#language)
    attr_accessor :language

    # @!attribute address
    # @return [Hash]
    attr_accessor :address

    def initialize(args = {})
      @api_key  = args[:api_key]
      @language = args[:language]
      @address  = args[:address]
    end

    # @abstract Abstract base method for generating a URL with which to call a
    #   maps API
    # @return [String] a URL to use in calling a maps API
    def generate_url
      raise NeedToOveride, 'generate_url'
    end

    private

    # Translate a hash into a query string
    # @param hash [Hash] the object to be transformed
    # @return [String] a URL query
    def hash_to_query(hash)
      URI.encode_www_form(hash)
    end
  end
end
