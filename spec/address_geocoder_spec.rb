describe AddressGeocoder do
  it 'has a global var with a list of countries' do
    expect(AddressGeocoder::COUNTRIES).to_not eq(nil)
  end

  it 'has a global var with regex' do
    expect(AddressGeocoder::REGEX).to_not eq(nil)
  end
end
