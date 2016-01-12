require 'spec_helper'

describe AddressGeocoder do
  describe 'when initialized' do
    it "should contain an array of countries" do
      test = AddressGeocoder.new
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
    it "should not show the refined address" do
      test = AddressGeocoder.new
      expect{test.refined_address}.to raise_error
    end
  end
end