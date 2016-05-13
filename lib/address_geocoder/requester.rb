require 'httparty'
require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for making requests to maps APIs
  class Requester
    # @!attribute [w] parser
    # @return [Parser] a class instance
    attr_writer :parser
    # @!attribute [w] address
    # @return [Hash] the address to use in the request
    attr_writer :address
    # @!attribute [w] language
    # @return [Hash] the language to return the request in
    attr_writer :language
    # @!attribute [w] api_key
    # @return [Hash] the api_key to use in the request
    attr_writer :api_key
    # @!attribute [r] result
    # @return [Hash] the result of a request to a maps API
    attr_reader :result

    def initialize(args = {})
      @parser = args[:parser]
    end

    # Make a call to a maps API
    # @return [void]
    def make_call
      raise NeedToOveride, 'make_call'
    end

    # @abstract Abstract base method for initiating a call to a maps API
    # @return [Boolean] true, or false if the request failed
    def success?
      raise NeedToOveride, 'success?'
    end

    # Raise a connection error
    def connection_error(msg)
      raise ConnectionError, msg
    end
  end
end
