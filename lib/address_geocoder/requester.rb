require 'httparty'
require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for making requests to maps APIs
  class Requester
    attr_accessor :result

    def initialize(url)
      attempts = 0
      begin
        @result = HTTParty.get(url)
      rescue
        sleep(0.5)
        attempts += 1
        retry if attempts <= 5
        failure('Could not connect to GoogleAPI')
      end
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
