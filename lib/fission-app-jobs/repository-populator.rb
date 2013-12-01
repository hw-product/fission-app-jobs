require 'fission/callback'

module Fission
  module App
    class Jobs < Fission::Callback

      def setup(*args)
      end

      def valid?(message)
      end

      def execute(message)
      end
    end
  end
end
