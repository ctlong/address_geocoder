require 'httparty'

class Request # :nodoc:
  attr_accessor :result

  def initialize(url)
    attempts = 0
    begin
      @result = HTTParty.get(url)
    rescue
      sleep(0.5)
      attempts += 1
      retry if attempts <= 5
      raise SystemCallError, 'Could not connect to GoogleAPI'
    end
  end

  def success?
    return false unless @result['status'] == 'OK'
    return false unless @result['results'][0]['address_components'].length > 1
    true
  end
end
