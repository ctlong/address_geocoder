require 'yaml'
require 'httparty'
require 'uri'

module AddressGeocoder
  class Base
    REGEX             = /\A[a-zA-Z\ ]*\z/
    COUNTRIES         = YAML.load_file('lib/address_geocoder/countries.yaml')
    CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3, remove_state: 4 }.freeze
    CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze
    attr_accessor :api_key, :country, :state, :city, :postal_code, :street
    attr_reader :google_response, :former_address

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
      success? && @google_response['certainty']
    end

    def suggested_addresses
      call_google if values_changed?
      return false unless success?
      parse_response(@google_response['results'][0]['address_components'])
    end

    private

    def call_google
      # 1 initialize former address
      @former_address = {
        city: @city,
        street: @street,
        country: @country,
        postal_code: @postal_code,
        state: @state
      }

      # 2 Loop through the levels (once one works break the loop)
      call_levels.each do |level_of_search|

        # 2.1 Make call to Google
        attempts = 0
        begin
          @google_response = HTTParty.get(get_final_url(level_of_search))
        rescue
          sleep(0.5)
          attempts += 1
          if attempts <= 5
            retry
          else
            raise SystemCallError, 'Could not connect to GoogleAPI'
          end
        end

        # 2.2 If the address succeeded:
        if success?
          set_certainty(level_of_search)
          break
        end
      end
    end

    def success?
      (@google_response['status'] == "OK") && (@google_response['results'][0]['address_components'].length > 1)
    end

    def set_certainty(level)
      if (3 == level || 7 == level) && valid_city?
        @google_response['certainty'] = false
      elsif (level == 4) && (valid_city? || valid_state?)
        @google_response['certainty'] = false
      elsif (level > 4) && !not_valid_postal_code?
        @google_response['certainty'] = false
      else
        @google_response['certainty'] = true
      end
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
      self.city && (self.city[REGEX] != '') # when city name does not match Regex will return nil
    end

    def valid_state?
      self.state && (self.state[REGEX] != '') # when city name does not match Regex will return nil
    end

    def get_final_url(level_of_search)
      address_params  = hash_to_query('country' => self.country)
      address_params += '|' + hash_to_query('postal_code' => self.postal_code) if level_of_search < 5
      address_params += '|' + hash_to_query('locality' => self.city) if valid_city? && !([3, 4, 7].select { |x| x == level_of_search }).any?
      address_params += '|' + hash_to_query('administrative_area' => self.state) if valid_state? && (level_of_search != 4)
      address_params.tr!('\=', ':')

      street          = hash_to_query('address' => self.street) + '&' if ([1,5].select { |x| x == level_of_search }).any?
      address_params += "&key=#{self.api_key}" unless self.api_key.empty?
      language        = nil # country == 'CN' ? "&language=zh-CN" : nil

      "https://maps.googleapis.com/maps/api/geocode/json?#{street}components=#{address_params}#{language}"
    end

    def call_levels
      levels  = [CYCLEWITHPOSTAL[:all], CYCLEWITHNOPOSTAL[:all]]
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
      postal_code = self.postal_code.to_s.tr(' ', '')
      return true unless match_country['postal_code']
      return true if postal_code.length < 3
      return true if postal_code.tr(postal_code[0], '') == '' && !(postal_code[0].to_i.in? Array(1..9))
      false
    end

    def values_changed?
      return true unless @google_response
      current_address = {
        city: @city,
        street: @street,
        country: @country,
        postal_code: @postal_code,
        state: @state
      }
      current_address == @former_address
    end

    def hash_to_query(hash)
      URI.encode_www_form(hash)
    end
  end
end
