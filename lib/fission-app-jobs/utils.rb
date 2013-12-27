module Fission
  module App
    module Jobs

      module Github

        # base:: Base resource
        # key:: Key to retrieve data
        # Follows all pages and returns data.
        def fetch_all(base, key)
          result = []
          resource = base.rels[key].get
          result += [resource.data].flatten(1).compact
          while(resource.rels[:next])
            resource = resource.rels[:next].get
            result += [resource.data].flatten(1).compact
          end
          if(block_given?)
            yield result
          else
            result
          end
        end

      end

      extend Github

      class Utils

        include Github

        def run!(*args)
          raise NoMethodError.new 'Abstract method. Concrete method not found!'
        end

      end

    end
  end
end
