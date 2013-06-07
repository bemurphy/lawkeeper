module Lawkeeper
  module ScopeFinders
    class Ohm
      def self.call(scope)
        scope.key.split(':')[0]
      end
    end
  end
end
