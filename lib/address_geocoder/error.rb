module AddressGeocoder
  # @abstract Abstract base class for errors
  class Error < RuntimeError
  end

  # Class that defines an error, to be thrown when a method needs to be
  # overwritten by a child class.
  class NeedToOveride < Error
    def initialize(msg = nil)
      @msg = msg
    end

    def message
      msg = 'This Method Needs To Be Overridden'
      @msg ? "#{msg}: #{@msg}" : msg
    end
  end

  # Class that defines an error representing a failure in connection with a
  # third party Maps API
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
