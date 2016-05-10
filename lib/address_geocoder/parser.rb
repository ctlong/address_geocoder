module AddressGeocoder
  # Abstract base class for parsing maps API responses
  # @abstract
  class Parser
    def initialize(fields, suggested_address)
      @fields            = fields
      @suggested_address = suggested_address
    end
  end
end
