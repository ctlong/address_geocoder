module AddressGeocoder
  # @abstract Abstract base class for parsing maps API responses
  class Parser
    def initialize(fields, suggested_address)
      @fields            = fields
      @suggested_address = suggested_address
    end
  end
end
