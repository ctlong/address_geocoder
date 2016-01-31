class Parse # :nodoc:
  def initialize(opts = {})
    @street  = opts[:steet]
    @level   = opts[:level]
    @api_key = opts[:api_key]
    @address = prune(opts)
  end

  def self.value_present?(level, comparison_array, value)
    ([level] & comparison_array).any? && value
  end
end
