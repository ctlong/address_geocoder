require 'address_geocoder/error'

module AddressGeocoder
  # Abstract base class for interacting with maps APIs
  # @abstract
  class Client
    REGEX = /\A[a-zA-Z\ ]*\z/
    attr_accessor :api_key, :country, :state, :city, :postal_code, :street,
                  :language
    attr_reader :response, :former_address

    def initialize(args = {})
      assign_initial(args)
      unless @country && @country[/\A[a-zA-Z]{2}\z/] && match_country
        raise ArgumentError, 'Invalid country'
      end
    end

    # Determines whether an address is likely to be valid or not
    # @return [true, false] true, or false if address is likely to be invalid
    def valid_address?
      # 1. If address values have changed call api
      call if values_changed?
      # 2. Return T/F depending on success of call and certainty of success
      @response.success? && @response.result['certainty']
    end

    # Gathers a list of improved addresses
    def suggested_addresses
      # 1. If address values have changed call api
      call if values_changed?
      # 2. If response failed return false
      return false unless @response.success?
      # 3. Initialize refined_address
      country_wo_postal = match_country.reject { |k| k == :postal_code }
      refined_address = { country: country_wo_postal, city: nil, state: nil, postal_code: nil, street: nil }
      # 4. Pass refined address and google response to parser
      parser = MapsApi::Google::Parser.new(@response.result['results'][0]['address_components'], refined_address)
      # 5. return parsed google response as suggested address
      parser.parse_google_response
    end

    # Abstract base method for initiating a call to a maps API
    # @abstract
    def call
      raise NeedToOveride, 'call'
    end

    private

    # Assigns the entered variables to their proper instance variables
    # @return [void]
    def assign_initial(args)
      Client.instance_methods(false).each do |var|
        next if var.to_s[/\=/].nil?
        title = var.to_s.tr('=', '')
        instance_variable_set("@#{title}", args[title.to_sym].to_s)
      end
    end

    # Determines whether the inputted country exists in countries yaml
    # @return [Hash, nil] A country object, or nil if no country matched
    def match_country
      COUNTRIES[@country]
    end

    # Determines whether the inputted address values have changed in any way
    # @return [true, false] true, or false if nothing has been called or the
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

    def valid_city?
      @city && (@city[REGEX] != '') # nil if city name does not match Regex
    end

    def valid_state?
      @state && (@state[REGEX] != '') # nil if city name does not match Regex
    end

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
      # 5. Else true
      true
    end
  end
end
