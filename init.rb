require 'trashed'

metrics = Trashed::Metrics.available
message = metrics.any? ? metrics.map(&:label).join(', ') : 'none available'
Rails.logger.info "[Trashed] metrics: #{message}"
