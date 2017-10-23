module Barnes
  module Instruments
    # Tracks out of band GCs that occurred *since* the last request.
    class GctoolsOobgc
      def start!(state)
        state[:oobgc] = current
      end

      def instrument!(state, counters, gauges)
        last = state[:oobgc]
        cur = state[:oobgc] = current

        counters.update \
          :'OOBGC.count'        => cur[:count] - last[:count],
          :'OOBGC.major_count'  => cur[:major] - last[:major],
          :'OOBGC.minor_count'  => cur[:minor] - last[:minor],
          :'OOBGC.sweep_count'  => cur[:sweep] - last[:sweep]
      end

      private def current
        {
          :count => GC::OOB.stat(:count).to_i,
          :major => GC::OOB.stat(:major).to_i,
          :minor => GC::OOB.stat(:minor).to_i,
          :sweep => GC::OOB.stat(:sweep).to_i
        }
      end
    end
  end
end
