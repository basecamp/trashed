require 'trashed/test_helper'
require 'trashed/instruments/ruby_gc_profiler'

if defined? GC::Profiler
  class RubyGCProfilerTest < Minitest::Test
    def setup
      super
      @instrument = Trashed::Instruments::RubyGCProfiler.new
      GC::Profiler.enable
      GC::Profiler.clear
    end

    def teardown
      GC::Profiler.disable
    end

    def test_records_out_of_band_gc_count_and_time
      assert_records_gc_count_and_time :start, :OOBGC
    end

    def test_records_gc_count_and_time
      assert_records_gc_count_and_time :measure, :GC
    end

    private
    def assert_records_gc_count_and_time(method, captured)
      GC.start
      GC.start

      if GC::Profiler.respond_to? :raw_data
        elapsed = GC::Profiler.raw_data.inject(0) { |sum, d| sum + d[:GC_TIME] }
        intervals = GC::Profiler.raw_data.map { |d| d[:GC_INVOKE_TIME] }
      end

      timings, gauges = {}, []
      @instrument.send method, nil, timings, gauges

      assert_equal 2, timings[:"#{captured}.count"]

      if GC::Profiler.respond_to? :raw_data
        assert_equal elapsed, timings[:"#{captured}.time"]
        assert_equal intervals, timings[:'GC.interval']
      end
    end
  end
end
