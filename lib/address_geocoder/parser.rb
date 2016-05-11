module AddressGeocoder
  # @abstract Abstract base class for parsing maps API responses
  class Parser
    # @!attribute addresses
    # @return [Array<Hash>] a list of our address objects
    attr_accessor :addresses
    # @!attribute [w] fields
    # @return [Hash] a maps API response
    attr_writer :fields

    def initialize(args = {})
      @addresses = args[:addresses]
      @fields    = args[:fields]
    end
  end
end
