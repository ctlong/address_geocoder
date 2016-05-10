# Namespace for classes and modules directly relating to the gem
# @since 0.0.1
module AddressGeocoder
  # Abstract base class for parsing Maps API responses
  # @abstract
  # @since 0.0.1
  class Parser
    def initialize(fields, suggested_address)
      @fields            = fields
      @suggested_address = suggested_address
    end
  end
end
