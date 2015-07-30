require 'base64'

class JobsController < ApplicationController

  before_action :set_job_account
  before_action :set_valid_jobs

  def all
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @jobs = @valid_jobs.order(:created_at.desc).paginate(page, per_page)
        @progress = (@jobs.all.map(&:percent_complete).sum.to_f / @jobs.count)
        @namespace = @product.internal_name if @namespace.nil?
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
        else
          @logs = Smash.new.tap do |logs|
            @job.payload.fetch(:data, {}).each do |k,v|
              if(v && v.is_a?(Hash) && v[:logs])
                v[:logs].each do |args|
                  if(args.is_a?(Array))
                    name, key = *args
                  else
                    i ||= 1
                    name = "Log #{i}"
                    i = i.next
                    key = args
                  end
                  begin
                    if(Rails.env.to_s == 'development')
                      logs[name] = Rails.application.config.fission_assets.get(key).read
                    else
                      logs[name] = Rails.application.config.fission_assets.url(key, 500)
                    end
                  rescue => e
                    logs[name] = 'FILE NOT FOUND!'
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def job_status
    respond_to do |format|
      format.js do
        last_id = params[:last_id].to_i
        @job = @valid_jobs.where(:message_id => params[:job_id]).first
        @events = @job.events.where{ id > last_id }.order(:stamp.asc).all
      end
      format.html do
        flash[:error] = 'Unsupported request'
        redirect_to dashboard_path
      end
    end
  end

  protected

  def set_valid_jobs
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

  def set_job_account
    if(params[:job_id])
      @preload_job = Job.where(:message_id => params[:job_id]).last
      if(@preload_job && @preload_job.account_id && @preload_job.account_id != @account.id)
        redirect_to send(
          "#{@namespace}_job_path",
          :job_id => params[:job_id],
          :account_id => @preload_job.accound.id
        )
      end
    end
  end

end
