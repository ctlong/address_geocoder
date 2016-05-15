require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for interacting with maps APIs
  class Client
    # @!attribute api_key
    # @return [String] the user's key to the chosen maps API
    attr_accessor :api_key
    # @!attribute language
    # @return [String] the language in which to return the address
    attr_accessor :language
    # @!attribute [r] address
    # @return [Hash] our address object. It contains country, state, city,
    #   postal code, and street.
    attr_reader :address
    # @!attribute [r] response
    # @return [Hash] the response from the maps API
    attr_reader :response
    # @!attribute [r] former_address
    # @return [Hash] the address that was last called from the maps API
    attr_reader :former_address

    def initialize(args = {})
      @address = {}
      assign_initial(args)
    end

    # Determines whether an address is likely to be valid or not
    # @return [Boolean] true, or false if address is likely to be invalid
    # @todo .certain? should be a parser method
    def valid_address?
      check_country
      if values_changed?
        reset
        @requester.make_call
      end
      @requester.success? && @requester.certain?
    end

    # Gathers a list of matching addresses from the maps API
    # @return [Array<Hash>] a list of matching addresses
    def suggested_addresses
      check_country
      if values_changed?
        reset
        @requester.make_call
      end
      return false unless @requester.success?
      @requester.array_result.map do |result|
        @parser.fields = result
        @parser.parse_response
      end
      # unless Client.instance_methods(false).include?(:suggested_addresses)
      #   raise NeedToOveride, 'suggested_addresses'
      # end
    end

    # @abstract Assigns the entered variables to their proper instance variables
    # @param args [Hash] arguments to pass to the class
    # @option args [String] :country a country's alpha2
    # @option args [String] :api_key the user's key to the chosen maps API
    # @option args [String] :state the state of the address to be validated
    # @option args [String] :city the city of the address to be validated
    # @option args [String] :postal_code the postal code of the address to be
    #   validated
    # @option args [String] :street the street of the address to be validated
    # @option args [String] :language (en) the language in which to return the
    #   address
    # @return [void]
    def assign_initial(args)
      raise NeedToOveride, 'assign_initial' unless @requester && @parser
      Client.instance_methods(false).each do |var|
        next if var.to_s[/\=/].nil?
        value = args[var.to_s.tr('=', '').to_sym].to_s
        next unless value
        send(var, value)
      end
    end

    def country=(str)
      @address[:country]          = COUNTRIES[str]
      @address[:country][:alpha2] = str if @address[:country]
    end

    def state=(str)
      @address.delete(:state)
      @address[:state] = simple_check_and_assign!(str)
    end

    def city=(str)
      @address.delete(:city)
      @address[:city] = simple_check_and_assign!(str)
    end

    def postal_code=(str)
      @address.delete(:postal_code)
      @address[:postal_code] = pc_check_and_assign!(str)
    end

    def street=(str)
      @address[:street] = nil
      @address[:street] = str unless str.empty?
    end

    private

    # Determines whether the given alpha2 exists in the countries yaml
    # @raise [ArgumentError] if the given value is not an alpha2 or does not
    #   match any country in the yaml
    # @return [void]
    def check_country
      raise ArgumentError, 'Invalid country' unless @address[:country]
    end

    # Resets the former address to new data
    # @return [void]
    def reset
      @former_address     = @address
      @parser.address     = @address
      @requester.address  = @address
      @requester.language = @language
      @requester.api_key  = @api_key
    end

    # Determines whether the inputted address values have changed in any way
    # @return [Boolean] true, or false if nothing has been called or the
    # current address information does not match the information from when the
    # maps API was last called
    def values_changed?
      return true unless @response
      @address != @former_address
    end

    # Determines whether the given state is valid or not
    # @return [Boolean] true, or false if the state name does not pass the Regex
    def simple_check_and_assign!(var)
      var if var.to_s[REGEX] != ''
    end

    # Determines whether the given postal code is valid or not
    # @return [Boolean] true, or false if the postal code does not pass the
    #   specs
    def pc_check_and_assign!(postal_code)
      # 1. Remove spaces
      pc = postal_code.to_s.tr(' ', '')
      # 2. False if country does not have postal codes
      return nil unless @address[:country][:has_postal_code]
      # 3. False if postal code length is not at least 4
      return nil if pc.length < 3
      # 4. False if postal code is all one char (if that char isn't 1-9)
      all_one_char = pc.tr(pc[0], '') == ''
      return nil if all_one_char && !(pc[0].to_i.in? Array(1..9))
      pc
    end
  end
end
