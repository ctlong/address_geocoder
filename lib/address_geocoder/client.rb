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
    # @return [Boolean] true, or false if address is likely to be invalid.
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

    # Matches the given alpha2 to a yaml country and assigns it to the address
    # object
    # @param str [String] a country's alpha2
    # @return [Hash, nil] a country object from the yaml, or nil if the provided
    #   alpha2 could not be matched.
    def country=(str)
      if COUNTRIES[str]
        @address[:country]          = COUNTRIES[str]
        @address[:country][:alpha2] = str
      else
        @address[:country] = nil
      end
      @address[:country]
    end

    # Assigns the given state to the address object if it passes verification
    # @param str [String] a state name
    # @return [String, nil] the entered state, or nil if the provided string
    #   could not be verified.
    def state=(str)
      @address[:state] = simple_check_and_assign!(str)
    end

    # Assigns the given city to the address object if it passes verification
    # @param str [String] a city name
    # @return [String, nil] the entered city, or nil if the provided string
    #   could not be verified.
    def city=(str)
      @address[:city] = simple_check_and_assign!(str)
    end

    # Assigns the given postal code to the address object if it passes
    # verification
    # @param str [String] a postal code
    # @return [String, nil] the entered postal code, or nil if the provided
    #   string could not be verified.
    def postal_code=(str)
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
    #   current address information does not match the information from when the
    #   maps API was last called
    def values_changed?
      return true unless @response
      @address != @former_address
    end

    # Determines whether the given city/state is valid or not
    # @param var [String] a city/state name
    # @return [String, nil] the given city/state, or false if it does not pass
    #   the Regex
    def simple_check_and_assign!(var)
      var if var.to_s[REGEX] != ''
    end

    # Determines whether the given postal code is valid or not
    # @note validations include checking length, whether or not the given
    #   country has a postal code, and checking to make sure the postal code is
    #   not all one letter or all 0.
    # @param postal_code [String, Integer] a postal code
    # @return [String, nil] the given postal code as a string, or nil if it is
    #   not valid.
    def pc_check_and_assign!(postal_code)
      pc = postal_code.to_s.tr(' ', '')
      return nil unless @address.fetch(:country).fetch(:has_postal_code)
      return nil if pc.length < 3
      all_one_char = pc.delete(pc[0]) == ''
      return nil if all_one_char && !(pc[0].to_i.in? Array(1..9))
      pc
    end
  end
end
