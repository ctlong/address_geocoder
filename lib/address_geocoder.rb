require 'yaml'

class AddressGeocoder
  ValidCountryAlpha2 = /\A[a-zA-Z]{2}\z/
  ValidCityName =  /\A[a-zA-Z\ ]*\z/
  attr_accessor :api_key, :country, :state, :city, :postal_code, :street
  attr_reader :countries, :google_response, :former_address

  def initialize(opt = {})
    # 1. Initialize variables
    @api_key          = opt[:api_key]
    @country          = opt[:country]
    @state            = opt[:state]
    @city             = opt[:city]
    @postal_code      = opt[:postal_code]
    @street           = opt[:street]
    @countries        = YAML.load_file('lib/address_geocoder/countries.yaml')['countries']['country']
    match_country
  end

  def valid_address?
    call_google if values_have_changed
    return success?
  end

  def suggested_addresses
    call_google if values_have_changed
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
          raise
        end
      end

      # 2.2 Break if the address succeeded
      break if success?
    end
  end

  def success?
    return (@google_response['status'] == "OK") && (@google_response['results'][0]['address_components'].length > 1)
  end

  def match_country
    if @country && @country[ValidCountryAlpha2]
      return @countries[@country]
    end
    raise ArgumentError, 'Invalid country'
  end

  def parse_response(fields)
    refined_address  = {country: match_country}
    has_neighborhood = false
    has_locality     = false
    fields.each do |field|
      parse_field(field['types'][0], has_neighborhood, has_locality, refined_address)
    end
  end

  def parse_field(fields, has_neighborhood, has_locality, refined_address)
    case field
    when 'neighborhood'
      refined_address[:city] = field['long_name']
      has_neighborhood = true
    when 'locality'
      if has_neighborhood
        refined_address[:state] = field['long_name']
        has_locality = true
      else
        refined_address[:city] = field['long_name']
      end
    when 'administrative_area_level_4', 'administrative_area_level_3', 'administrative_area_level_2'
      if has_neighborhood && has_locality
        refined_address[:city] = refined_address[:state]
        has_neighborhood = false
      end
      refined_address[:state] = field['long_name']
    when 'administrative_area_level_1'
      if has_neighborhood && has_locality
        refined_address[:city] = refined_address[:state]
        has_neighborhood = false
      end
      refined_address[:state] = field['short_name']
    when 'postal_code'
      refined_address[:postal_code] = field['long_name']
    end
  end

  def has_valid_city?
    return self.city && self.city[ValidCityName] # when city name does not match Regex will return nil
  end

  def get_final_url(level_of_search)
    country         = match_country['alpha2']

    address_params  = country.to_query("country")
    address_params += '|' + self.postal_code.to_query("postal_code") if (4.in? get_format_levels) && (level_of_search < 5)
    address_params += '|' + self.city.to_query("locality") if has_valid_city? && !(level_of_search.in? [3,4,7])
    address_params += '|' + self.state.to_query("administrative_area") if self.state && (level_of_search != 4)
    address_params.gsub!(/\=/,':')

    street          = self.street.to_query("address") + '&' if level_of_search.in? [1,5]
    api_key         = "&key=#{self.api_key}"
    language        = country == 'CN' ? "&language=zh-CN" : nil #TODO add more languages

    return "https://maps.googleapis.com/maps/api/geocode/json?#{street}components=#{address_params}#{api_key}#{language}"
  end

  def get_format_levels
    levels  = [1,5]
    levels += [2,6] if has_valid_city?
    levels += [3,7] if self.state
    if not_valid_postal_code?
      levels  -= [5,6,7]
    else
      levels  += [4]
    end
    return levels.sort!
  end

  def not_valid_postal_code?
    return true unless match_country['postal_code']
    return true if self.postal_code.length < 3
    return true if ((self.postal_code.gsub(' ', '').gsub("#{self.postal_code[0]}",'') == '') and !(self.postal_code[0].in? Array(1..9)))
    return false
  end

  def values_have_changed
    if @google_response
      current_address = {
        city: @city,
        street: @street,
        country: @country,
        postal_code: @postal_code,
        state: @state
      }
      if current_address == @former_address
        return false
      end
    end
    return true
  end
end
