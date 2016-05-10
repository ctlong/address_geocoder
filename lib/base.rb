require 'yaml'
require 'base/error'
require 'base/parser'
require 'base/request'
require 'base/url'

module Base
  REGEX             = /\A[a-zA-Z\ ]*\z/
  COUNTRIES         = YAML.load_file('lib/address_geocoder/countries.yaml')
  CYCLEWITHPOSTAL   = { all: 1, remove_street: 2, remove_city: 3, remove_state: 4 }.freeze
  CYCLEWITHNOPOSTAL = { all: 5, remove_street: 6, remove_city: 7 }.freeze

  def valid_address?
    # 1. If address values have changed call google
    call_google if values_changed?
    # 2. Return T/F depending on success of call and certainty of success
    @response.success? && @response.result['certainty']
  end

  def suggested_addresses
    # 1. If address values have changed call google
    call_google if values_changed?
    # 2. If response failed return false
    return false unless @response.success?
    # 3. Initialize refined_address
    country_wo_postal = match_country.reject { |k| k == :postal_code }
    refined_address = { country: country_wo_postal, city: nil, state: nil, postal_code: nil, street: nil }
    # 4. Pass refined address and google response to parser
    parser = Base::Parser::Google.new(@response.result['results'][0]['address_components'], refined_address)
    # 5. return parsed google response as suggested address
    parser.parse_google_response
  end

  private

  def call_google
    # 1 initialize former address
    @former_address = { city: @city, street: @street, country: @country, postal_code: @postal_code, state: @state }
    # 2 Loop through the levels (once one works break the loop)
    call_levels.each do |level_of_search|
      # 2.1 Set url
      request_hash = @former_address.merge(level: level_of_search, api_key: @api_key, language: @language)
      request_hash.delete(:city) unless valid_city?
      request_hash.delete(:state) unless valid_state?
      request_url = Base::Url.new(request_hash)
      # 2.2 Make call to google
      @response = Base::Request.new(request_url.formulate)
      # 2.3 If the address succeeded:
      if @response.success?
        @response.result['certainty'] = evaluate_certainty(level_of_search)
        break
      end
    end
  end

  def evaluate_certainty(level)
    # False if only returned country
    return false if Base::Parser::Google.just_country?(@response)
    # False if country is not inputted country
    return false if !Base::Parser::Google.correct_country?(@response, @country)
    # False if had valid city but level didn't include city
    return false if Base::Parser::Google.value_present?(level, [3, 4, 7], valid_city?)
    # False if had valid state but level didn't include state
    return false if Base::Parser::Google.value_present?(level, [4], valid_state?)
    # False if had valid postal code but level didn't include postal code
    return false if Base::Parser::Google.value_present?(level, [5, 6, 7], valid_postal_code?)
    # Else true
    true
  end

  def match_country
    COUNTRIES[@country] # returns matched country from countries yaml
  end

  def valid_city?
    @city && (@city[REGEX] != '') # nil if city name does not match Regex
  end

  def valid_state?
    @state && (@state[REGEX] != '') # nil if city name does not match Regex
  end

  def call_levels
    # 1. Init levels
    levels  = []
    # 2. Assign base levels unless no street
    levels += [CYCLEWITHPOSTAL[:all], CYCLEWITHNOPOSTAL[:all]] unless @street.empty?
    # 3. Assign levels that don't use street if valid city
    levels += [CYCLEWITHPOSTAL[:remove_street], CYCLEWITHNOPOSTAL[:remove_street]] if valid_city?
    # 4. Assign levels that don't use street,city if valid state
    levels += [CYCLEWITHPOSTAL[:remove_city], CYCLEWITHNOPOSTAL[:remove_city]] if valid_state?
    # 5. If valid postal code:
    if valid_postal_code?
      # 5.1 Assign the level that doesn't use street,city,state
      levels  += [CYCLEWITHPOSTAL[:remove_state]]
    # 6. Else:
    else
      # 6.1 Remove all levels that included postal code
      levels  -= CYCLEWITHPOSTAL.values
    end
    # 7. Return sorted array
    levels.sort!
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

  def values_changed?
    # True If no previous google response stored
    return true unless @response
    # Return the comparison of current and former addresses
    current_address = {
      city: @city,
      street: @street,
      country: @country,
      postal_code: @postal_code,
      state: @state
    }
    current_address != @former_address
  end
end
