require 'base64'

class JobsController < ApplicationController

  before_action do
    @valid_jobs = Job.dataset_with(
      :scalars => {
        :route => ['data', 'router', 'action'],
        :status => ['status']
      }
    ).where(
      :route => params[:namespace].to_s,
      :account_id => current_user.run_state.current_account.id
    )
  end

  def all
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @jobs = @valid_jobs.order(:created_at.desc).paginate(page, per_page)
        @progress = (@jobs.all.map(&:percent_complete).sum.to_f / @jobs.count)
        @namespace = @product.internal_name
        enable_pagination_on(@jobs)
      end
    end
  end

  def details
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @job = @valid_jobs.where(:message_id => params[:job_id]).first
        unless(@job)
          @job = Job.find_by_id(params[:job_id])
          if(@job && @job.account_id != @account.id)
            namespace = job.payload.get(:data, :router, :action)
            if(namespace && respond_to?("#{namespace}_job_path"))
              redirect_to send("#{namespace}_job_path", job.message_id, :account_id => @account.id)
            else
              redirect_to job_path(job.message_id)
            end
          else
            flash[:error] = "Failed to locate requested job (ID: #{params[:job_id]})"
            redirect_to dashboard_path
          end
        end
      end
    end
  end

end
