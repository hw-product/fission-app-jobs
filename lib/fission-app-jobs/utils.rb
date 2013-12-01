module Fission
  module App
    module Jobs

      class Utils

        def run!(*args)
          raise NoMethodError.new 'Abstract method. Concrete method not found!'
        end

      end

    end
  end
end
