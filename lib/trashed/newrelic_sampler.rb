if ObjectSpace.respond_to?(:live_objects) && agent = NewRelic::Agent.instance
  agent.stats_engine.add_sampled_metric 'Ruby/Live Objects' do |stats|
    stats.record_data_point ObjectSpace.live_objects
  end
end
