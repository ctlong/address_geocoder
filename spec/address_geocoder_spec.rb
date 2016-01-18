require 'spec_helper'
describe AddressGeocoder do
  describe 'when initialized' do
    it "should contain an array of countries" do
      test = AddressGeocoder.new({country: 'US', city: 'Phoenix'})
      expect(test.countries).to eq(YAML.load_file('lib/address_geocoder/countries.yaml')['countries']['country'])
    end
    it "should have attr accessors" do
      test = AddressGeocoder.new({api_key: '12345', country: 'US', state: 'CO', street: '301 First St.', city: 'Crested Butte', postal_code: '10022'})

      expect(test.api_key).to eq('12345')
      expect(test.country).to eq('US')
      expect(test.state).to eq('CO')
      expect(test.street).to eq('301 First St.')
      expect(test.city).to eq('Crested Butte')
    end
    it "should not have called google" do
      test = AddressGeocoder.new({country: 'US', city: 'Phoenix'})
      expect(test.google_response).to eq(nil)
    end
  end

  describe "#valid_address?" do
    context "when address can be not recognized" do
      it "returns false" do
        # when only city
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo'})
        expect(address_geocoder.valid_address?).to eq(false)
        # when only postal code
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: 'A6000A'})
        expect(address_geocoder.valid_address?).to eq(false)
        # when only state
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Ohio'})
        expect(address_geocoder.valid_address?).to eq(false)
        # when only street
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: '10, On Lok Mun Street'})
        expect(address_geocoder.valid_address?).to eq(false)
        # when city vs postal code
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', postal_code: '102600'})
        expect(address_geocoder.valid_address?).to eq(false)
        # when city vs state
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Tokyo', state: 'Liaoning'})
        expect(address_geocoder.valid_address?).to eq(false)
      end
      it "adds errors message in an instance of address_geocoder"
    end

    context "when address can be recogized" do
      it "returns true" do
        # when only city
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when only postal code
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'BR', postal_code: '01501-000'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when only state
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'JP', state: 'Saitama'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when only street
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CH', street: 'Brunngasshalde'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when city vs postal code
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CN', city: 'Beijing', postal_code: '100050'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when city vs state
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when postal code vs street
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'BR', city: 'Belo Horizonte', state: 'Minas Gerais'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when postal code vs state
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'GR', state: 'Eastern Macedonia and Thrace', postal_code: '671 00'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when street, city, state
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'CI', street: 'Boulevard Houphouët-Boigny', city: 'San-Pédro', state: 'Bas-Sassandra'})
        expect(address_geocoder.valid_address?).to eq(true)
        # when street, city, postal_code
        address_geocoder = AddressGeocoder.new({api_key: ENV['AddressGeocoderApiKey'], country: 'FR', street: '8 Boulevard Léon Bureau', city: 'Nantes', postal_code: '44200'})
        expect(address_geocoder.valid_address?).to eq(true)
      end
    end
  end

  describe "#suggested_address" do
    context "when address can be not recogized" do
      it "returns nil"
      it "adds errors message in an instance of address_geocoder"
    end

    context "when address can be recogized" do
      it "returns a hash with keys: country state city postal_code street"
    end
  end
end