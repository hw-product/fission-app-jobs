require 'fission/callback'
require 'fission-app-jobs/utils/account_populator'

module Fission
  module App
    module Jobs
      class AccountPopulator < Fission::Callback

        def valid?(message)
          super do |m|
            retrieve(m, :data, :app, :job) == 'account_populator'
          end
        end

        def execute(message)
          payload = unpack(message)
          Utils::AccountPopulator.new.run!(retrieve(payload, :data, :app))
          job_completed(:app_jobs, payload, message)
        end
      end
    end
  end
end

Fission.register(:app_jobs, :account_populator, Fission::App::Jobs::AccountPopulator)
