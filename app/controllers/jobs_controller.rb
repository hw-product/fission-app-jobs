class JobsController < ApplicationController

  before_action do
    if(params[:account_id])
      @account = current_user.accounts.detect do |act|
        act.id = params[:account_id].to_i
      end
      @jobs = @account.jobs_dataset
    else
      @jobs = Job.dataset.where(:account_id => current_user.accounts.map(&:id))
    end
  end

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        if(@account)
          javascript_redirect_to account_jobs_path(@account)
        else
          javascript_redirect_to jobs_path
        end
      end
      format.html do
        @jobs = @jobs.order(:created_at.desc).paginate(page, per_page)
        enable_pagination_on(@jobs)
      end
    end
  end

  def show
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        if(@account)
          javascript_redirect_to account_jobs_path(@account)
        else
          javascript_redirect_to jobs_path
        end
      end
      format.html do
        @job = @jobs.where(:id => params[:id]).first
        @history = @jobs.where(:message_id => @job.message_id).order(:created_at.desc)
        unless(@job)
          if(@account)
            javascript_redirect_to account_jobs_path(@account)
          else
            javascript_redirect_to jobs_path
          end
        end
      end
    end
  end

end
