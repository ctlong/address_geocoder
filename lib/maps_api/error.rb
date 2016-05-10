module MapsApi
  class Error < RuntimeError # Base Error of AddressGeocoder
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
