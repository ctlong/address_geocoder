require 'uri'

module AddressGeocoder
  # Abstract base class for generatoring URLs to call maps APIs
  # @abstract
  class UrlGenerator
    def initialize(opts = {})
      @street   = opts[:street]
      @level    = opts[:level]
      @api_key  = opts[:api_key]
      @language = opts[:language]
      @address  = prune(opts)
    end
  end
end
