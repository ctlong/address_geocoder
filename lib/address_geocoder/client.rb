require 'address_geocoder/error'

module AddressGeocoder
  # @abstract Abstract base class for interacting with maps APIs
  class Client
    # The regex used to check the state and city for validity
    REGEX = /\A[a-zA-Z\ ]*\z/

    # @!attribute country
    # @return [String, Hash] a country's alpha2 or a country object from
    #   the yaml
    attr_accessor :country
    # @!attribute api_key
    # @return [String] the user's key to the chosen maps API
    attr_accessor :api_key
    # @!attribute state
    # @return [String] the state of the address to be validated
    attr_accessor :state
    # @!attribute city
    # @return [String] the city of the address to be validated
    attr_accessor :city
    # @!attribute postal_code
    # @return [String] the postal code of the address to be validated
    attr_accessor :postal_code
    # @!attribute street
    # @return [String] the street of the address to be validated
    attr_accessor :street
    # @!attribute language
    # @return [String] the language in which to return the address
    attr_accessor :language
    # @!attribute [r] response
    # @return [Hash] the response from the maps API
    attr_reader :response
    # @!attribute [r] former_address
    # @return [Hash] the address that was last called from the maps API
    attr_reader :former_address

    def initialize(args = {})
      assign_initial(args)
    end

    # Determines whether an address is likely to be valid or not
    # @return [Boolean] true, or false if address is likely to be invalid
    def valid_address?
      check_country
      if values_changed?
        reset_former_address
        call
        # @url_generator.generate_url
        # @requester.make_call
      end
      @requester.success? && @requester.result['certainty']
      # @requester.success? && @parser.certain?
    end

    # Gathers a list of matching addresses from the maps API
    # @return [Array<Hash>] a list of matching addresses
    def suggested_addresses
      check_country
      if values_changed?
        reset_former_address
        call
      end
      return false unless @requester.success?
      # 3. Initialize refined_address
      country_wo_postal = match_country.reject { |k| k == :postal_code }
      refined_address = { country: country_wo_postal, city: nil, state: nil, postal_code: nil, street: nil }
      # 4. Pass refined address and google response to parser
      @parser.fields    = @requester.result['results'][0]['address_components']
      @parser.addresses = refined_address
      # 5. return parsed google response as suggested address
      @parser.parse_google_response
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
    # @option args [String] :language (en) the language in which to return the address
    # @return [void]
    def assign_initial(args)
      unless @url_generator && @requester && @parser
        raise NeedToOveride, 'assign_initial'
      end
      Client.instance_methods(false).each do |var|
        next if var.to_s[/\=/].nil?
        title = var.to_s.tr('=', '')
        value = args[title.to_sym].to_s
        next unless value
        instance_variable_set("@#{title}", value)
      end
    end

    # @abstract Abstract base method for resetting the former address
    # @return [void]
    def reset_former_address
      raise NeedToOveride, 'reset_former_address'
    end

    # @abstract Abstract base method for initiating a call to a maps API
    # @return [void]
    def call
      raise NeedToOveride, 'call'
    end

    private

    # Determines whether the given alpha2 exists in the countries yaml
    # @raise [ArgumentError] if the given value is not an alpha2 or does not
    #   match any country in the yaml
    # @return [void]
    def check_country
      unless @country && @country[/\A[a-zA-Z]{2}\z/] && match_country
        raise ArgumentError, 'Invalid country'
      end
    end

    # Attempts to match the given alpha2 to a country in the countries yaml
    # @return [Hash, nil] A country object, or nil if no country matched
    def match_country
      COUNTRIES[@country]
    end

    # Determines whether the inputted address values have changed in any way
    # @return [Boolean] true, or false if nothing has been called or the
    # current address information does not match the information from when the
    # maps API was last called
    def values_changed?
      return true unless @response
      current_address = {
        city: @city,
        street: @street,
        country: @country,
        postal_code: @postal_code,
        state: @state
      }
      current_address != @former_address
    end

    # Determines whether the given city is valid or not
    # @return [Boolean] true, or false if the city name does not pass the Regex
    def valid_city?
      @city && (@city[REGEX] != '')
    end

    # Determines whether the given state is valid or not
    # @return [Boolean] true, or false if the state name does not pass the Regex
    def valid_state?
      @state && (@state[REGEX] != '')
    end

    # Determines whether the given postal code is valid or not
    # @return [Boolean] true, or false if the postal code does not pass the
    #   specs
    def valid_postal_code?
      # 1. Remove spaces
      postal_code = @postal_code.to_s.tr(' ', '')
      # 2. False if country does not have postal codes
      return false unless match_country[:postal_code]
      # 3. False if postal code length is not at least 4
      return false if postal_code.length < 3
      # 4. False if postal code is all one char (if that char isn't 1-9)
      all_one_char = postal_code.tr(postal_code[0], '') == ''
      return false if all_one_char && !(postal_code[0].to_i.in? Array(1..9))
      true
    end
  end
end
