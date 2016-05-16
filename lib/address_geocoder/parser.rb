require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for parsing maps API responses
  class Parser
    # @!attribute [w] address
    # @return [Hash] an address object
    attr_writer :address
    # @!attribute [w] fields
    # @return [Hash] a maps API response
    attr_writer :fields

    def initialize(args = {})
      @address = args[:address]
      @fields  = args[:fields]
    end

    # @abstract Abstract base method for parsing maps API responses
    # @return (see AddressGeocoder::Client#suggested_addresses)
    def parse_response
      raise NeedToOveride, 'parse_response'
    end
  end
end
