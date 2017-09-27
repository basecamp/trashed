module Trashed
  module Instruments
    class ObjectSpaceCounter
      def measure(state, counters, gauges)
        ObjectSpace.count_objects.each do |type, count|
          gauges << [ :"Objects.#{type}", count ]
        end
      end
    end
  end
end
