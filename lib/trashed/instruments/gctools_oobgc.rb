module Trashed
  module Instruments
    # Tracks out of band GCs that occurred *since* the last request.
    class GctoolsOobgc
      def start(state, counters, gauges)
        last = state[:persistent][:oobgc] || Hash.new(0)

        current = {
          :count => GC::OOB.stat(:count).to_i,
          :major => GC::OOB.stat(:major).to_i,
          :minor => GC::OOB.stat(:minor).to_i,
          :sweep => GC::OOB.stat(:sweep).to_i }

        counters.update \
          :'OOBGC.count'        => current[:count] - last[:count],
          :'OOBGC.major_count'  => current[:major] - last[:major],
          :'OOBGC.minor_count'  => current[:minor] - last[:minor],
          :'OOBGC.sweep_count'  => current[:sweep] - last[:sweep]

        state[:persistent][:oobgc] = current
      end

      def measure(state, counters, gauges)
      end
    end
  end
end
