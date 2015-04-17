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
        @state = case @job.status
                 when :success, :complete
                     'success'
                   when :error
                     'danger'
                   else
                     'warn'
                   end
        unless(@job)
          flash[:error] = "Failed to locate requested job (ID: #{params[:job_id]})"
          redirect_to dashboard_path
        end

        @table_data =  [['Timestamp', @job.created_at],
                        ['Account', @job.account.name],
                        ['Status', @job.status.to_s.humanize],
                        ['Completed', @job.percent_complete]]
      end
    end
  end

end
