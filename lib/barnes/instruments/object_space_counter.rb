module Barnes
  module Instruments
    class ObjectSpaceCounter
      def instrument!(state, counters, gauges)
        ObjectSpace.count_objects.each do |type, count|
          gauges[:"Objects.#{type}"] = count
        end
      end
    end
  end
end
