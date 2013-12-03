require 'fission/callback'
require 'fission-app-jobs/utils/repository-populator'

module Fission
  module App
    module Jobs
      class RepositoryPopulator < Fission::Callback

        def valid?(message)
          super do |m|
            retrieve(m, :data, :app, :job) == 'repository_populator'
          end
        end

        def execute(message)
          payload = unpack(message)
          Utils::RepositoryPopulator.new.run!(retrieve(payload, :data, :app))
          job_completed(:app_jobs, payload, message)
        end
      end
    end
  end
end

Fission.register(:app_jobs, :repository_populator, Fission::App::Jobs::RepositoryPopulator)
