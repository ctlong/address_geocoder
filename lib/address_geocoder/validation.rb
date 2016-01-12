module AddressGeocoder
  class Validation
    attr_accessor :api_key, :country, :state, :city, :postal_code, :street
    attr_reader :countries
    attr_writer :refined_address

    def initialize(opt = {})
      # 1. Initialize variables
      @api_key     = opt[:api_key]
      @country     = opt[:country]
      @state       = opt[:state]
      @city        = opt[:city]
      @postal_code = opt[:postal_code]
      @street      = opt[:street]

      # 2. attempt to load yaml
      begin
        @countries = YAML.load_file('yaml/countries.yaml')
      rescue LoadError
        puts 'cannot load country yaml'
        raise
      end
    end

    def result
      return refine_address rescue false
    end

    private
    def refine_address
      # 1. Initialize refined address
      refined_address = {
        :city   => nil,
        :state  => nil,
        :country => nil,
        :street   => nil,
        :postal_code => nil
      }
      @countries['countries'].each do |k,v|
        if k == @country

      # 2. Loop through the levels (once one works break the loop)
      get_format_levels.each do |level_of_search|

        # 2.1 Make call to Google
        attempts = 0
        begin
          address_response = HTTParty.get(get_final_url(level_of_search))
        rescue
          attempts += 1
          if attempts <= 5
            retry
          else
            raise
          end
        end

        # 2.2 If the address succeeded:
        if (address_response['status'] == "OK") && (address_response['results'][0]['address_components'].length > 1)

          # 2.2.1 Parse the address
          parse_response(address_response['results'][0]['address_components'], refined_address)
          
          # 2.2.2 Return refined address
          return refined_address
        end
      end
    end

    def parse_response(fields, address)
      has_neighborhood = false
      has_locality = false
      fields.each do |field|
        case field['types'][0]
          when 'neighborhood'
            address[:city] = field['long_name']
            has_neighborhood = true
          when 'locality'
            if has_neighborhood
              address[:state] = field['long_name']
              has_locality = true
            else
              address[:city] = field['long_name']
            end
          when 'administrative_area_level_4', 'administrative_area_level_3', 'administrative_area_level_2'
            if has_neighborhood && has_locality
              address[:city] = address[:state]
              has_neighborhood = false
            end
            address[:state] = field['long_name']
          when 'administrative_area_level_1'
            if has_neighborhood && has_locality
              address[:city] = address[:state]
              has_neighborhood = false
            end
            address[:state] = field['short_name']
          when 'postal_code'
            address[:postal_code] = field['long_name']
          end
      end
      return true
    end

    def has_valid_city_name?
      return self.city[/[a-zA-Z]/].present?
    end

    def get_final_url(level_of_search)
      country         = @countries[@country]['iso_2']

      address_params  = country.to_query("country")
      address_params += '|' + self.postal_code.to_query("postal_code") if (4.in? get_format_levels) && (level_of_search < 5)
      address_params += '|' + self.city.to_query("locality") if has_valid_city_name? && !(level_of_search.in? [3,4,7])
      address_params += '|' + self.state.to_query("administrative_area") if self.state && (level_of_search != 4)
      address_params.gsub!(/\=/,':')

      street          = self.address_line_1.to_query("address") + '&' if level_of_search.in? [1,5]
      api_key         = "&key=#{ENV['GOOGLE_MAPS_KEY']}"
      language        = country == 'CN' ? "&language=zh-CN" : nil

      return "https://maps.googleapis.com/maps/api/geocode/json?#{street}components=#{address_params}#{api_key}#{language}"
    end

    def get_format_levels
      levels  = [1,5]
      levels += [2,6] if has_valid_city_name?
      levels += [3,7] if self.state
      if (self.country.in? Country::WITHOUT_POSTAL_CODE) && not_valid_postal_code?
        levels  -= [5,6,7]
      else
        levels  += [4]
      end
      return levels.sort!
    end

    def valid_postal_code?
      return false if self.postal_code.length < 3
      return false if ((self.postal_code.gsub(' ', '').gsub("#{self.postal_code[0]}",'') == '') and !(self.postal_code[0].in? Array(1..9)))
      return true
    end

    def not_valid_postal_code?
      return !(valid_postal_code?)
    end
  end
end