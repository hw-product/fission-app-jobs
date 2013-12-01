require 'fission/callback'
require 'fission-app-jobs/utils/repository-populator'

module Fission
  module App
    class Jobs < Fission::Callback

      def valid?(message)
        super do |m|
          retrieve(m, :data, :app, :job) == 'repository_populator'
        end
      end

      def execute(message)
        payload = unpack(message)
        user = retrieve(payload, :data, :app, :user)
        Utils::RepositoryPopulator.new.run!(user)
        job_completed(:app_job, payload, message)
      end
    end
  end
end

Fission.register(:app_job, :repository_populator, Fission::App::Jobs::RepositoryPopulator)
