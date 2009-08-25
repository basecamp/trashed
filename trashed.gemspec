# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{trashed}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Kemper"]
  s.date = %q{2009-08-24}
  s.email = %q{jeremy@bitsweat.net}
  s.files = ["MIT-LICENSE", "README", "lib/trashed", "lib/trashed/metrics", "lib/trashed/metrics/change.rb", "lib/trashed/metrics/compound.rb", "lib/trashed/metrics/lookup.rb", "lib/trashed/metrics/metric.rb", "lib/trashed/metrics.rb", "lib/trashed/newrelic", "lib/trashed/newrelic/enable.rb", "lib/trashed/newrelic.rb", "lib/trashed/rack", "lib/trashed/rack/request_logger.rb", "lib/trashed/version.rb", "lib/trashed.rb"]
  s.homepage = %q{http://github.com/37signals/trashed}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Keep tabs on expensive Ruby garbage collection. Supports NewRelic RPM and Rack.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.0"])
  end
end
