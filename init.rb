require 'trashed/measurement'

if Trashed.available?
  Trashed.enable

  ActionController::Dispatcher.class_eval do
    before_dispatch { Trashed::Measurement.mark! }
    after_dispatch  { Trashed::Measurement.log! }
  end
else
  Rails.logger.info '*** Resource growth measurements disabled (running unpatched ruby) ***'
end
