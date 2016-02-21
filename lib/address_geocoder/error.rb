class AddressGeocoder
  class Error < RuntimeError # Base Error of AddressGeocoder
    attr_accessor :code
  end

  class ConnectionError < Error  # Specific Error for failure in connection to a third party map API
  end
end
