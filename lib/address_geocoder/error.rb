# Namespace for classes and modules directly relating to the gem
# @since 0.0.1
module AddressGeocoder
  class Error < RuntimeError # Base Error of AddressGeocoder
  end

  class NeedToOveride < Error
    def initialize(msg = nil)
      @msg = msg
    end

    def message
      msg = 'This Method Needs To Be Overrided'
      @msg ? "#{msg}: #{@msg}" : msg
    end
  end

  # Specific Error for failure in connection to a third party map API
  class ConnectionError < Error
    def initialize(msg = nil)
      @msg = msg
    end

    def message
      msg = 'Failed To Connect'
      @msg ? "#{msg}: #{@msg}" : msg
    end
  end
end
