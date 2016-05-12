require 'httparty'
require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for making requests to maps APIs
  class Requester
    # The regex used to check the state and city for validity
    REGEX = /\A[a-zA-Z\ ]*\z/

    # @!attribute [r] result
    # @return [Hash] the result of a request to a maps API
    attr_reader :result

    def initialize
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
