module Trashed
  module Instruments
    class ObjectSpaceCounter
      def measure(state, timings, gauges)
        ObjectSpace.count_objects.each do |type, count|
          gauges << [ :"Objects.#{type}", count ]
        end
      end
    end
  end
end
