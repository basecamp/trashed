require 'rails/railtie'
require 'barnes/reporter'
require 'barnes/resource_usage'

module Barnes
  class Railtie < ::Rails::Railtie
    config.barnes = {
      :interval => 10,
      :statsd => nil,
      :panels => [],
    }

    initializer 'barnes' do |app|
      require 'statsd'

      sample_rate = config.barnes[:interval] / 60.0
      panels = config.barnes[:panels]

      if config.barnes[:statsd]
        reporter = Barnes::Reporter.new(config.barnes[:statsd], sample_rate)

        unless config.barnes[:panels].length > 0
          panels << Barnes::ResourceUsage.new(sample_rate)
        end

        Periodic.new reporter, sample_rate, panels
      end
    end
  end
end
