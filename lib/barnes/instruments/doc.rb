# A note on gauges being used as counters.
#
# The sample_rate argument allows for the parameterization
# of instruments that decide to report data as gauges, that
# would typically be reported as counters.
#
# Aggregating counters is typically done simply with the `+`
# operator, which doesn't preserve the number of unique
# reporters that contributed to the count, or allow for one
# to learn the *average* of the counts posted.
#
# A gauge is typically aggregated by simply *replacing* the
# previous value, however, some systems do *more* with gauges
# when aggregating across multiple sources of that gauge, like,
# average, or compute stdev.
#
# This is problematic, however, when a gauge is being used as
# a counter, to preserve the average / stdev computational
# properties from above, because the interval that the gauge
# is being read it, affects the derivative of the increasing
# count. Instead of the derivative over 60s, the derivative is
# taken every 10s, giving us a derivative value that's approximately
# 1/6th of the actual derivative over 60s.
#
# We compensate for this by allowing Instruments to correct for
# this, and ensure that, even though it's an estimate, the data
# is scaled appropriately to the target aggregation interval, not
# just the collection interval.
