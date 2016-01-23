require 'yaml'
require 'httparty'
require 'uri'

class AddressGeocoder
  ValidCountryAlpha2     = /\A[a-zA-Z]{2}\z/
  ValidName              = /\A[a-zA-Z\ ]*\z/
  Countries              = YAML.load_file('lib/address_geocoder/countries.yaml')['countries']['country']
  CycleWithPostalCode    = {:all => 1, :remove_street => 2, :remove_city => 3, :remove_state  => 4}
  CycleWithoutPostalCode = {:all => 5, :remove_street => 6, :remove_city => 7}
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
    raise ArgumentError, 'Invalid country' unless @country && @country[ValidCountryAlpha2] && Countries[@country]
  end

  def valid_address?
    call_google if values_changed?
    return success? && @google_response['certainty']
  end

  def suggested_addresses
    call_google if values_changed?
    return false unless success?
    return parse_response(@google_response['results'][0]['address_components'])
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
    get_format_levels.each do |level_of_search|

      # 2.1 Make call to Google
      attempts = 0
      begin
        @google_response = HTTParty.get(get_final_url(level_of_search))
      rescue
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
    return (@google_response['status'] == "OK") && (@google_response['results'][0]['address_components'].length > 1)
  end

  def set_certainty(level)
    if (3 == level || 7 == level) && has_valid_city?
      @google_response['certainty'] = false
    elsif (level == 4) && (has_valid_city? || has_valid_state?)
      @google_response['certainty'] = false
    elsif (level > 4) && !(not_valid_postal_code?)
      @google_response['certainty'] = false
    else
      @google_response['certainty'] = true
    end
  end

  def match_country
    Countries[@country]
  end

  def parse_response(fields)
    refined_address  = {country: match_country.reject { |k,v| k == 'postal_code' }, city: nil, state: nil, postal_code: nil, street: nil}
    fields.each { |field| parse_field(field, refined_address) }
    refined_address.delete(:switch)
    return refined_address
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

  def has_valid_city?
    return self.city && (self.city[ValidName] != '') # when city name does not match Regex will return nil
  end

  def has_valid_state?
    return self.state && (self.state[ValidName] != '') # when city name does not match Regex will return nil
  end

  def get_final_url(level_of_search)
    address_params  = hash_to_query({"country" => self.country})
    address_params += '|' + hash_to_query({"postal_code" => self.postal_code}) if level_of_search < 5
    address_params += '|' + hash_to_query({"locality" => self.city}) if has_valid_city? && !([3,4,7].select { |x| x == level_of_search }).any?
    address_params += '|' + hash_to_query({"administrative_area" => self.state}) if has_valid_state? && (level_of_search != 4)
    address_params.gsub!(/\=/,':')

    street          = hash_to_query({"address" => self.street}) + '&' if ([1,5].select { |x| x == level_of_search }).any?
    api_key         = "&key=#{self.api_key}" unless self.api_key.empty?
    language        =  nil #country == 'CN' ? "&language=zh-CN" : nil

    return "https://maps.googleapis.com/maps/api/geocode/json?#{street}components=#{address_params}#{api_key}#{language}"
  end

  def get_format_levels
    levels  = [CycleWithPostalCode[:all], CycleWithoutPostalCode[:all]]
    levels += [CycleWithPostalCode[:remove_street], CycleWithoutPostalCode[:remove_street]] if has_valid_city?
    levels += [CycleWithPostalCode[:remove_city], CycleWithoutPostalCode[:remove_city]] if has_valid_state?
    if not_valid_postal_code?
      levels  -= CycleWithPostalCode.values
    else
      levels  += [CycleWithPostalCode[:remove_state]]
    end
    return levels.sort!
  end

  def not_valid_postal_code?
    return true unless match_country['postal_code']
    return true if self.postal_code.length < 3
    return true if ((self.postal_code.gsub(' ', '').gsub("#{self.postal_code[0]}",'') == '') and !(self.postal_code[0].in? Array(1..9)))
    return false
  end

  def values_changed?
    if @google_response
      current_address = {city: @city, street: @street, country: @country, postal_code: @postal_code, state: @state}
      if current_address == @former_address
        return false
      end
    end
    return true
  end

  def hash_to_query(hash)
    URI.encode_www_form(hash)
  end
end
