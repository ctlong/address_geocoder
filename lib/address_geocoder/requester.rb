require 'httparty'
require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for making requests to maps APIs
  class Requester
    attr_accessor :result

    def initialize
    end

    def make_call
      raise NeedToOveride, 'make_call'
    end

    # @abstract Abstract base method for initiating a call to a maps API
    # @return [Boolean] true, or false if the request failed
    def success?
      raise NeedToOveride, 'success?'
    end

    def failure(msg)
      raise ConnectionError, msg
    end
  end
end
