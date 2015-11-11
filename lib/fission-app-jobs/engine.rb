module FissionApp
  module Jobs
    class Engine < ::Rails::Engine
    end

    # Provide proc for dynamic route injections.
    #
    # @return [Proc] block for injecting routes
    def self.jobs_routes
      Proc.new do |namespace, disable_details=false|
        get(
          "#{namespace}/jobs(/:payload_filter/:payload_value)",
          :defaults => {
            :namespace => namespace
          },
          :to => 'jobs#all',
          :as => "#{namespace}_jobs"
        )
        unless(disable_details)
          get(
            "#{namespace}/job/:job_id",
            :defaults => {
              :namespace => namespace
            },
            :to => 'jobs#details',
            :as => "#{namespace}_job"
          )
        end
        get(
          "#{namespace}/job/:job_id/status",
          :defaults => {
            :namespace => namespace
          },
          :to => 'jobs#job_status',
          :as => "#{namespace}_job_status"
        )
      end
    end

    def self.custom_job_details
      @@custom_job_details
    end

    @@custom_job_details = []

  end
end
