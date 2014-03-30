module Trashed
  module Instruments
    class Ruby20GC
      def start(state)
        gc = GC.stat
        state.update \
          :'GC.count'             => gc[:count],
          :'GC.allocated_objects' => gc[:total_allocated_object],
          :'GC.freed_objects'     => gc[:total_freed_object]
      end

      def measure(state, timings, gauges)
        gc = GC.stat

        timings.update \
          :'GC.count'             => gc[:count] - state.delete(:'GC.count'),
          :'GC.allocated_objects' => gc[:total_allocated_object] - state.delete(:'GC.allocated_objects'),
          :'GC.freed_objects'     => gc[:total_freed_object] - state.delete(:'GC.freed_objects')

        gauges.concat gc.map { |k, v| [ :"GC.#{k}", v ] }
      end
    end
  end
end
