module Trashed
  module WithoutGc
    def handle_request
      GC.disable
      super
    ensure
      GC.enable
    end
  end
end
