require 'base'

# Main gem class to be called
class AddressGeocoder
  include Base

  attr_accessor :api_key, :country, :state, :city, :postal_code, :street,
                :language
  attr_reader :response, :former_address

  def initialize(args = {})
    assign_initial(args)
    unless @country && @country[/\A[a-zA-Z]{2}\z/] && match_country
      raise ArgumentError, 'Invalid country'
    end
  end

  def assign_initial(args)
    %w(api_key country state city postal_code street language).each do |var|
      instance_variable_set("@#{var}", args[var.to_sym].to_s)
    end
  end
end
