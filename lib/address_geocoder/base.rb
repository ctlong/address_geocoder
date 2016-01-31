require 'yaml'

module AddressGeocoder
  class Base # :nodoc:
    autoload :Request, File.expand_path('../request', __FILE__)
    autoload :Url,     File.expand_path('../url', __FILE__)
    autoload :Parse,   File.expand_path('../parse', __FILE__)

    REGEX             = /\A[a-zA-Z\ ]*\z/
    COUNTRIES         = YAML.load_file('lib/address_geocoder/countries.yaml')
    CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3, remove_state: 4 }.freeze
    CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze

    attr_accessor :api_key, :country, :state, :city, :postal_code, :street
    attr_reader :response, :former_address

    def initialize(opt = {})
      # 1. Initialize variables
      @api_key     = opt[:api_key] || ''
      @country     = opt[:country]
      @state       = opt[:state] || ''
      @city        = opt[:city] || ''
      @postal_code = opt[:postal_code] || ''
      @street      = opt[:street] || ''
      raise ArgumentError, 'Invalid country' unless @country && @country[/\A[a-zA-Z]{2}\z/] && COUNTRIES[@country]
    end

    def valid_address?
      call_google if values_changed?
      @response.success? && @response.result['certainty']
    end

    def suggested_addresses
      call_google if values_changed?
      return false unless @response.success?
      parse_response(@response.result['results'][0]['address_components'])
    end

    private

    def call_google
      # 1 initialize former address
      @former_address = { city: @city, street: @street, country: @country, postal_code: @postal_code, state: @state }
      # 2 Loop through the levels (once one works break the loop)
      call_levels.each do |level_of_search|
        # 2.1 Set url
        request_hash = @former_address.merge(level: level_of_search, api_key: @api_key)
        request_hash.delete(:city) unless valid_city?
        request_hash.delete(:state) unless valid_state?
        request_url = Url.new(request_hash)
        # 2.2 Make call to google
        @response = Request.new(request_url.formulate)
        # 2.3 If the address succeeded:
        if @response.success?
          @response.result['certainty'] = evaluate_certainty(level_of_search)
          break
        end
      end
    end

    def evaluate_certainty(level)
      return false if Parse.value_present?(level, [3, 4, 7], valid_city?)
      return false if Parse.value_present?(level, [4], valid_state?)
      return false if Parse.value_present?(level, [5, 6, 7], valid_postal_code?)
      true
    end

    def match_country
      COUNTRIES[@country]
    end

    def parse_response(fields)
      refined_address = { country: match_country.reject { |k| k == 'postal_code' }, city: nil, state: nil, postal_code: nil, street: nil }
      fields.each { |field| parse_field(field, refined_address) }
      refined_address.delete(:switch)
      refined_address
    end

    def parse_field(field, refined_address)
      case field['types'][0]
      when 'neighborhood', 'locality'
        if refined_address[:city]
          refined_address[:state]  = field['long_name']
          refined_address[:switch] = true
        else
          refined_address[:city] = field['long_name']
        end
      when 'administrative_area_level_4', 'administrative_area_level_3', 'administrative_area_level_2'
        if refined_address[:switch]
          refined_address[:city]   = refined_address[:state]
          refined_address[:switch] = false
        end
        refined_address[:state] = field['long_name']
      when 'administrative_area_level_1'
        if refined_address[:switch]
          refined_address[:city]   = refined_address[:state]
          refined_address[:switch] = false
        end
        refined_address[:state] = field['short_name']
      when 'postal_code', 'postal_code_prefix'
        refined_address[:postal_code] = field['long_name']
      when 'route'
        refined_address[:street] = field['long_name']
      end
    end

    def valid_city?
      @city && (@city[REGEX] != '') # when city name does not match Regex will return nil
    end

    def valid_state?
      @state && (@state[REGEX] != '') # when city name does not match Regex will return nil
    end

    def call_levels
      levels  = []
      levels += [CYCLEWITHPOSTAL[:all], CYCLEWITHNOPOSTAL[:all]] unless @street.empty?
      levels += [CYCLEWITHPOSTAL[:remove_street], CYCLEWITHNOPOSTAL[:remove_street]] if valid_city?
      levels += [CYCLEWITHPOSTAL[:remove_city], CYCLEWITHNOPOSTAL[:remove_city]] if valid_state?
      if not_valid_postal_code?
        levels  -= CYCLEWITHPOSTAL.values
      else
        levels  += [CYCLEWITHPOSTAL[:remove_state]]
      end
      levels.sort!
    end

    def not_valid_postal_code?
      !valid_postal_code?
    end

    def valid_postal_code?
      postal_code = @postal_code.to_s.tr(' ', '')
      return false unless match_country['postal_code']
      return false if postal_code.length < 3
      return false if postal_code.tr(postal_code[0], '') == '' && !(postal_code[0].to_i.in? Array(1..9))
      true
    end

    def values_changed?
      return true unless @response
      current_address = {
        city: @city,
        street: @street,
        country: @country,
        postal_code: @postal_code,
        state: @state
      }
      current_address == @former_address
    end
  end
end
