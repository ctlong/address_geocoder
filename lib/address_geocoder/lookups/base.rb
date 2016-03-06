module Geocoder
  module Lookup

    class Base
      def initialize
        @cache = nil
      end

      ##
      # Human-readable name of the geocoding API.
      #
      def name
        fail 
        # Take reference #alexreisner/geocoder,
        # this syntax reminds the subclass to create the new method#name to replace,
        # if subclass don't have, it will raise error
      end

    end
  end
end
