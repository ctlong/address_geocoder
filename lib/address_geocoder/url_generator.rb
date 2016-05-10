require 'uri'

# Namespace for classes and modules directly relating to the gem
# @since 0.0.1
module AddressGeocoder
  # Abstract base class for generatoring URLs to call maps APIs
  # @abstract
  # @since 0.0.1
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
