require 'spec_helper'
describe AddressGeocoder do
  describe 'when initialized' do
    it 'should throw an error if the country is not recognized' do
      expect { AddressGeocoder.new(country: 'United States', city: 'Phoenix') }.to raise_error
    end
    it 'should have attr accessors' do
      address_geocoder = AddressGeocoder.new(api_key: '12345', country: 'US', state: 'CO', street: '301 First St.', city: 'Crested Butte', postal_code: '10022')

      expect(address_geocoder.api_key).to eq('12345')
      expect(address_geocoder.country).to eq('US')
      expect(address_geocoder.state).to eq('CO')
      expect(address_geocoder.street).to eq('301 First St.')
      expect(address_geocoder.city).to eq('Crested Butte')
    end
    it 'should not have called google' do
      address_geocoder = AddressGeocoder.new(country: 'US', city: 'Phoenix')
      expect(address_geocoder.response).to eq(nil)
    end
  end

  describe '#valid_address?' do
    context 'when address can be not recognized' do
      it 'returns false' do
        # when only city
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1)
        # when only postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: 'A6000A')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1)
        # when only state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Ohio')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1)
        # when only street
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: '10, On Lok Mun Street')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1)
        # when city vs postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', postal_code: '102600')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1)
        # when city vs state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', state: 'Liaoning')
        expect(address_geocoder.valid_address?).to eq(false)
      end
      it 'adds errors message in an instance of address_geocoder'
    end

    context 'when address can be recogized' do
      it 'returns true' do
        # when only city
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when only postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: '01501-000')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when only state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Saitama')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when only street
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: 'Brunngasshalde')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when city vs postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when city vs state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when postal code vs street
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when postal code vs state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'GR', state: 'Eastern Macedonia and Thrace', postal_code: '671 00')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when street, city, state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CI', street: 'Boulevard Houphouët-Boigny', city: 'San-Pédro', state: 'Bas-Sassandra')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1)
        # when street, city, postal_code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200')
        expect(address_geocoder.valid_address?).to eq(true)
      end
    end
  end

  describe '#suggested_address' do
    context 'when address can be not recogized' do
      it 'returns false' do
        # when only city
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo')
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1)
        # when only postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: 'A6000A')
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1)
        # when only state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Ohio')
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1)
        # when only street
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: '10, On Lok Mun Street')
        expect(address_geocoder.suggested_addresses).to eq(false)
        # when correct city vs wrong state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Hangzhou', state: 'Osaka Prefecture')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1)
      end
      it 'adds errors message in an instance of address_geocoder'
    end

    context 'when address is not valid, but can still be recognized' do
      it 'returns a hash with keys: country state city postal_code street' do
        # when wrong city vs correct postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', postal_code: '102600')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'China', alpha3: 'CHN' }, postal_code: '102600', city: 'Beijing', street: nil, state: 'Beijing')
        sleep(1)
        # when correct city vs wrong postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: 'AE102600')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'China', alpha3: 'CHN' }, postal_code: nil, city: 'Beijing', street: nil, state: 'Beijing')
        sleep(1)
        # when wrong city vs correct state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', state: 'Liaoning')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'China', alpha3: 'CHN' }, postal_code: nil, city: nil, street: nil, state: 'Liaoning')
        sleep(1)
      end
    end

    context 'when address can be recogized' do
      it 'returns a hash with keys: country state city postal_code street' do
        # when only city
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'US', city: 'Seattle')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'United States', alpha3: 'USA' }, city: 'Seattle', state: 'WA', street: nil, postal_code: nil)
        sleep(1)
        # when only postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: '01501-000')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'Brazil', alpha3: 'BRA' }, city: 'São Paulo', state: 'SP', street: nil, postal_code: '01501')
        sleep(1)
        # when only state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Saitama')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'Japan', alpha3: 'JPN' }, city: nil, state: 'Saitama Prefecture', street: nil, postal_code: nil)
        sleep(1)
        # when only street
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: 'Brunngasshalde')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'Switzerland', alpha3: 'CHE' }, city: 'Bern', state: 'BE', street: 'Brunngasshalde', postal_code: '3011')
        sleep(1)
        # when city vs postal code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'China', alpha3: 'CHN' }, city: 'Beijing', state: 'Beijing', street: nil, postal_code: '100050')
        sleep(1)
        # when city vs state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'Brazil', alpha3: 'BRA' }, city: 'Belo Horizonte', state: 'MG', street: nil, postal_code: nil)
        sleep(1)
        # when postal code vs street
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'US', postal_code: '10022', street: '475 Madison Ave')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'United States', alpha3: 'USA' }, city: 'New York', state: 'NY', street: 'Madison Avenue', postal_code: '10022')
        sleep(1)
        # when postal code vs state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'GR', state: 'Eastern Macedonia and Thrace', postal_code: '671 00')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'Greece', alpha3: 'GRC' }, city: nil, state: 'Makedonia Thraki', street: nil, postal_code: '671 00')
        sleep(1)
        # when street, city, state
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CI', street: 'Boulevard Houphouët-Boigny', city: 'San-Pédro', state: 'Bas-Sassandra')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'Ivory Coast', alpha3: 'CIV' }, city: 'San-Pédro', state: 'Bas-Sassandra', street: 'Boulevard Houphouët-Boigny', postal_code: nil)
        sleep(1)
        # when street, city, postal_code
        address_geocoder = AddressGeocoder.new(api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200')
        expect(address_geocoder.suggested_addresses).to eq(country: { country_name: 'France', alpha3: 'FRA' }, city: 'Nantes', state: 'Pays de la Loire', street: 'Boulevard Léon Bureau', postal_code: '44200')
      end
    end
  end
end
