class Parse # :nodoc:
  CITY_TYPES   = %w(neighborhood locality sublocality).freeze
  STATE_TYPES  = %w(administrative_area_level_4 administrative_area_level_3 administrative_area_level_2).freeze
  POSTAL_TYPES = %w(postal_code postal_code_prefix).freeze

  def initialize(fields, suggested_address)
    @fields            = fields
    @suggested_address = suggested_address
  end

  def parse_google_response
    @fields.each { |field| parse_field(field) }
    @suggested_address.delete(:switch)
    @suggested_address
  end

  def parse_field(field)
    @field = field
    if contains?(CITY_TYPES)
      matched_city(field['long_name'])
    elsif contains?(CITY_TYPES)
      matched_state(field['long_name'])
    elsif contains?(['administrative_area_level_1'])
      matched_state(field['short_name'])
    elsif contains?(POSTAL_TYPES)
      @suggested_address[:postal_code] = field['long_name']
    elsif contains?(['route'])
      @suggested_address[:street] = field['long_name']
    end
  end

  def self.value_present?(level, comparison_array, value)
    ([level] & comparison_array).any? && value
  end

  private

  def contains?(array)
    (@field['types'] & array).any?
  end

  def matched_city(value)
    if @suggested_address[:city]
      @suggested_address[:state]  = value
      @suggested_address[:switch] = true
    else
      @suggested_address[:city] = value
    end
  end

  def matched_state(value)
    if switched?
      @suggested_address[:city]   = @suggested_address[:state]
      @suggested_address[:switch] = false
    end
    @suggested_address[:state] = value
  end

  def switched?
    @suggested_address[:switch]
  end
end
