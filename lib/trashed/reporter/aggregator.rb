module Trashed
  module Reporter
    class Aggregator
      def initialize
        @reporters = []
      end

      def report(env)
        @reporters.each do |reporter|
          reporter.report(env)
        end
      end

      def add_reporter(reporter)
        @reporters << reporter if reporter && reporter.respond_to?(:report)
      end
    end
  end
end
