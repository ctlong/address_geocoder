require 'httparty'
require 'address_geocoder/error'

# Namespace for classes and modules directly relating to the gem
# @since 0.0.1
module AddressGeocoder
  # Abstract base class for making requests to Maps APIs
  # @abstract
  # @since 0.0.1
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

    def success?
      raise NeedToOveride, 'success?'
    end

    def failure(msg)
      raise ConnectionError, msg
    end
  end
end
