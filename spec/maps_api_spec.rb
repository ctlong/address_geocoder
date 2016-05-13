require 'spec_helper'
describe MapsApi, type: :libraries do
  describe 'when initialized' do
    it 'should have attr accessors' do
      address_geocoder = MapsApi::Google::Client.new(api_key: '12345', country: 'US', state: 'CO', street: '301 First St.', city: 'Crested Butte', postal_code: '10022')

      expect(address_geocoder.api_key).to eq('12345')
      expect(address_geocoder.address).to eq(
        country: {
          country_name: 'United States',
          alpha3: 'USA',
          has_postal_code: true,
          alpha2: 'US'
        },
        postal_code: '10022',
        state: 'CO',
        street: '301 First St.',
        city: 'Crested Butte'
      )
    end
    it 'should not have called google' do
      address_geocoder = MapsApi::Google::Client.new(country: 'US', city: 'Phoenix')
      expect(address_geocoder.response).to eq(nil)
    end
  end

  describe '#valid_address?' do
    it 'should throw an error if the country is not recognized' do
      expect { MapsApi::Google::Client.new(country: 'United States', city: 'Phoenix').valid_address? }.to raise_error
    end
    context 'when address can be not recognized' do
      it 'returns false' do
        # when only city
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1.5)
        # when only postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: 'A6000A')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1.5)
        # when only state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Ohio')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1.5)
        # when only street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: '10, On Lok Mun Street')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1.5)
        # when city vs postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', postal_code: '102600')
        expect(address_geocoder.valid_address?).to eq(false)
        sleep(1.5)
        # when city vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', state: 'Liaoning')
        expect(address_geocoder.valid_address?).to eq(false)
      end
      it 'adds errors message in an instance of address_geocoder'
    end

    context 'when address can be recogized' do
      it 'returns true' do
        # when only city
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when only postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: '01501-000')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when only state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Saitama')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when only street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: 'Brunngasshalde')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when city vs postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when city vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when postal code vs street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when postal code vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'GR', state: 'East Macedonia and Thrace', postal_code: '671 00')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when street, city, state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CI', street: 'Boulevard Houphouët-Boigny', city: 'San-Pédro', state: 'Bas-Sassandra')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when street, city, postal_code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200')
        expect(address_geocoder.valid_address?).to eq(true)
      end
    end

    context 'when address is of non-english and be recogized' do
      it 'returns true' do
        # when only city
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: '北京')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when only postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: '01501-000')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when only state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: '埼玉県')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when only street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: 'Brunngasshalde')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when city vs postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: '北京', postal_code: '100050')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when city vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when postal code vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'GR', state: 'East Macedonia and Thrace', postal_code: '671 00')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when street, city, state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CI', street: 'Boulevard Houphouët-Boigny', city: 'San-Pédro', state: 'Bas-Sassandra')
        expect(address_geocoder.valid_address?).to eq(true)
        sleep(1.5)
        # when street, city, postal_code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200')
        expect(address_geocoder.valid_address?).to eq(true)
      end
    end

    context 'when fail to call_google' do
      it 'will raise an error' do
        allow(HTTParty).to receive(:get).and_raise{ 'mocking a connection error' }
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050')
        expect{ address_geocoder.valid_address? }.to raise_error(AddressGeocoder::ConnectionError) { 'Could not connect to GoogleAPI' }
      end
    end
  end

  describe '#suggested_addresses' do
    it 'should throw an error if the country is not recognized' do
      expect { MapsApi::Google::Client.new(country: 'United States', city: 'Phoenix').suggested_addresses }.to raise_error
    end
    context 'when address can be not recogized' do
      it 'returns false' do
        # when only city
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1.5)
        # when only postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: 'A6000A')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1.5)
        # when only state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Ohio')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1.5)
        # when only street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: '10, On Lok Moon Street')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(false)
        # when correct city vs wrong state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Hangzhou', state: 'Osaka Prefecture')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq(false)
        sleep(1.5)
      end
      it 'adds errors message in an instance of address_geocoder'
    end

    context 'when address is not valid, but can still be recognized' do
      it 'returns a hash with keys: country state city postal_code street' do
        # when wrong city vs correct postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', postal_code: '102600')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'China', alpha3: 'CHN', alpha2: 'CN' }, postal_code: '102600', city: 'Beijing', street: nil, state: 'Beijing'])
        sleep(1.5)
        # when correct city vs wrong postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: 'AE102600')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'China', alpha3: 'CHN', alpha2: 'CN' }, postal_code: nil, city: 'Beijing', street: nil, state: 'Beijing'])
        sleep(1.5)
        # when wrong city vs correct state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', state: 'Liaoning')
        expect(address_geocoder.valid_address?).to eq(false)
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'China', alpha3: 'CHN', alpha2: 'CN' }, postal_code: nil, city: nil, street: nil, state: 'Liaoning'])
        sleep(1.5)
      end
    end

    context 'when address can be recogized' do
      it 'returns a hash with keys: country state city postal_code street' do
        # when only city
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'US', city: 'Seattle')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'United States', alpha3: 'USA', alpha2: 'US' }, city: 'Seattle', state: 'WA', street: nil, postal_code: nil])
        sleep(1.5)
        # when only postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: '01501-000')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Brazil', alpha3: 'BRA', alpha2: 'BR' }, city: 'São Paulo', state: 'SP', street: nil, postal_code: '01501'])
        sleep(1.5)
        # when only state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Saitama')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Japan', alpha3: 'JPN', alpha2: 'JP' }, city: nil, state: 'Saitama Prefecture', street: nil, postal_code: nil])
        sleep(1.5)
        # when only street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: 'Brunngasshalde')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Switzerland', alpha3: 'CHE', alpha2: 'CH' }, city: 'Bern', state: 'BE', street: 'Brunngasshalde', postal_code: '3011'])
        sleep(1.5)
        # when city vs postal code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'China', alpha3: 'CHN', alpha2: 'CN' }, city: 'Beijing', state: 'Beijing', street: nil, postal_code: '100050'])
        sleep(1.5)
        # when city vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Brazil', alpha3: 'BRA', alpha2: 'BR' }, city: 'Belo Horizonte', state: 'MG', street: nil, postal_code: nil])
        sleep(1.5)
        # when postal code vs street
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'US', postal_code: '10022', street: '475 Madison Ave')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'United States', alpha3: 'USA', alpha2: 'US' }, city: 'New York', state: 'NY', street: 'Madison Avenue', postal_code: '10022'])
        sleep(1.5)
        # when postal code vs state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'GR', state: 'Eastern Macedonia and Thrace', postal_code: '671 00')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Greece', alpha3: 'GRC', alpha2: 'GR' }, city: nil, state: 'Makedonia Thraki', street: nil, postal_code: '671 00'])
        sleep(1.5)
        # when street, city, state
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CI', street: 'Boulevard Houphouët-Boigny', city: 'San-Pédro', state: 'Bas-Sassandra')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: false, country_name: 'Ivory Coast', alpha3: 'CIV', alpha2: 'CI' }, city: 'San-Pédro', state: 'Bas-Sassandra', street: 'Boulevard Houphouët-Boigny', postal_code: nil])
        sleep(1.5)
        # when street, city, postal_code
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'France', alpha3: 'FRA', alpha2: 'FR' }, city: 'Nantes', state: 'Pays de la Loire', street: 'Boulevard Léon Bureau', postal_code: '44200'])
      end
    end

    context 'when a language is passed' do
      it 'returns suggested address from certain countries in different languages' do
        # when Japan return in Japanese
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Saitama', language: 'ja')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Japan', alpha3: 'JPN', alpha2: 'JP' }, city: nil, state: '埼玉県', street: nil, postal_code: nil])
        sleep(1.5)
        # when China return in Mandarin
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050', language: 'zh-CN')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'China', alpha3: 'CHN', alpha2: 'CN' }, city: '北京市', state: '北京市', street: nil, postal_code: '100050'])
        sleep(1.5)
        # when France return in French
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200', language: 'fr')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'France', alpha3: 'FRA', alpha2: 'FR' }, city: 'Nantes', state: 'Pays de la Loire', street: 'Boulevard Léon Bureau', postal_code: '44200'])
        sleep(1.5)
        # when Germany return in German
        address_geocoder = MapsApi::Google::Client.new(api_key: ENV['AddressGeocoderApiKey'], country: 'DE', postal_code: '12107', language: 'de')
        expect(address_geocoder.suggested_addresses).to eq([country: { has_postal_code: true, country_name: 'Germany', alpha3: 'DEU', alpha2: 'DE' }, city: 'Berlin', state: 'Berlin', street: nil, postal_code: '12107'])
      end
    end
  end
end