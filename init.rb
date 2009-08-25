require 'trashed'

metrics = Trashed::Metrics.available
message = metrics.any? ? metrics.map(&:label).join(', ') : 'unavailable'
Rails.logger.info "[Trashed] metrics: #{message}"
