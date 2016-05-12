require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for parsing maps API responses
  class Parser
    # @!attribute country
    # @return [Hash] a country object from the yaml
    attr_writer :country
    # @!attribute [w] fields
    # @return [Hash] a maps API response
    attr_writer :fields

    def initialize(args = {})
      @country = args[:country]
      @fields  = args[:fields]
    end

    # @abstract Abstract base method for parsing maps API responses
    # @return (see AddressGeocoder::Client#suggested_addresses)
    def parse_response
      raise NeedToOveride, 'parse_response'
    end
  end
end
