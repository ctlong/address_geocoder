module AddressGeocoder
  class Base

    def initialize()
    end

    def suggested_addresses
      # call lookup
      # return response to address geocoder
    end

    def valid_address?
      # call lookup
      # return response to address geocoder
    end

    private

    def lookup
      require "urls/#{api}"
      require "requests/#{api}"
      require "parsers/#{api}"
      # Get url
      # Redirect to requests
      # Redirect response to parser 
      # return to method
    end
  end
end