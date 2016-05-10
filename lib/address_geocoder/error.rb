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
end
