# Report.rb don't Know how to call Map API
# Know digest data from MapAPI Wrapper
# Know logics to compare results from different Map API
# Know the requirement of MapApiManager

# Reason to create report.rb: logics to compare results can be very complex

class AddressGeocoder
  module MapApis
    class Report
      def initialize(opt = {})
        # add attributes
        # also validation inputs
      end

      def prepare
        # take care logics to compare results from multi-MapApi
        # response a result in a format of MapApiManager expected
      end
    end
  end
end
