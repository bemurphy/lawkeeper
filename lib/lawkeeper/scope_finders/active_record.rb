module Lawkeeper
  module ScopeFinders
    class ActiveRecord
      def self.call(scope)
        scope.model_name
      end
    end
  end
end
