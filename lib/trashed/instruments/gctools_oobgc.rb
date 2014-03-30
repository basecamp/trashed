module Trashed
  module Instruments
    # Tracks out of band GCs that occurred *since* the last request.
    class GctoolsOobgc
      def start(state, timings, gauges)
        last = state[:persistent][:oobgc] || Hash.new(0)

        current = {
          :count => GC::OOB.stat(:count),
          :major => GC::OOB.stat(:major),
          :minor => GC::OOB.stat(:minor),
          :sweep => GC::OOB.stat(:sweep) }

        timings.update \
          :'OOBGC.count'        => current[:count] - last[:count],
          :'OOBGC.major_count'  => current[:major] - last[:major],
          :'OOBGC.minor_count'  => current[:minor] - last[:minor],
          :'OOBGC.sweep_count'  => current[:sweep] - last[:sweep]

        state[:persistent][:oobgc] = current
      end

      def measure(state, timings, gauges)
      end
    end
  end
end
