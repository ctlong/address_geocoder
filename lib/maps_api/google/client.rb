require 'address_geocoder/client'
require 'maps_api/google/parser'
require 'maps_api/google/requester'

module MapsApi
  module Google
    # Class for interacting with Google Maps API
    class Client < ::AddressGeocoder::Client
      # Assigns the entered variables to their proper instance variables
      # @param (see AddressGeocoder::Client#assign_initial)
      # @return (see AddressGeocoder::Client#assign_initial)
      def assign_initial(args)
        @requester     = Requester.new
        @parser        = Parser.new
        super args
      end

      # Initiates a call to GoogleMaps' Geocoding API
      # @return (see AddressGeocoder::Client#call)
      def call
        address = @former_address.dup
        @requester.make_call(address, @language, @api_key)
      end
    end
  end
end
