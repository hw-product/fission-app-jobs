module FissionApp
  module Jobs
    class Engine < ::Rails::Engine
    end

    # Provide proc for dynamic route injections.
    #
    # @return [Proc] block for injecting routes
    def self.jobs_routes
      Proc.new do |namespace|
        get "#{namespace}/jobs(/:payload_filter/:payload_value)", :defaults => {:namespace => namespace}, :to => 'jobs#all'
        get "#{namespace}/:account_id/jobs(/:payload_filter/:payload_value)", :defaults => {:namespace => namespace}, :to => 'jobs#list'
        get "#{namespace}/job/:job_id", :defaults => {:namespace => namespace}, :to => 'jobs#details'
      end
    end

  end
end
