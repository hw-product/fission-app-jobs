module FissionApp
  module Jobs
    class Engine < ::Rails::Engine
    end

    # Provide proc for dynamic route injections.
    #
    # @return [Proc] block for injecting routes
    def self.jobs_routes
      Proc.new do |namespace|
        get(
          "#{namespace}/jobs(/:payload_filter/:payload_value)",
          :defaults => {
            :namespace => namespace
          },
          :to => 'jobs#all',
          :as => "#{namespace}_jobs"
        )
        get(
          "#{namespace}/job/:job_id",
          :defaults => {
            :namespace => namespace
          },
          :to => 'jobs#details',
          :as => "#{namespace}_job"
        )
      end
    end

  end
end
