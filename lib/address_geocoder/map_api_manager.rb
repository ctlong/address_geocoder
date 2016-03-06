# Map API Manager don't Know HOW to do every action
# know WHAT to do and WHO to do
# know address_geocoder requirement

class AddressGeocoder
  class MapApiManager
    attr_reader :address, :map_apis, :action, :prority
    def initialize(option = {})
      # add attributes
      # also validation inputs
      @address  = option[:address]
      @map_apis = option[:map_apis]
      @map_apis.each do |api|
        require "address_geocoder/look/#{api}"
      end
      @action   = option[:action]
      @prority  = option[:prority]
    end

    def process
      # call MapApiWrappers
      results = {}
      map_apis.each do |map_api|
        ::AddressGeoder::Query.new(address: address, map_api: map_api, action: action)
        results[map_apis.to_sym] = map_api.excute
      end
      # call ReportWriter
      response = ::AddressGeoder::ReportWriter.new(results: results, prority: prority)
      # response a result in a format of address_geocoder expected
    end
  end
end
