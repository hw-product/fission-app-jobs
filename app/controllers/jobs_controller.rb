require 'base64'

class JobsController < ApplicationController

  prepend_before_action do
    if(params[:job_id])
      params[:account_id] = Job.find(params[:job_id]).try(:account_id)
    end
  end

  before_action do
    unless(@product)
      raise "Must define product for job listing. Full list currently disabled"
    end
    valid_jobs = Job.dataset.join_table(:left, :jobs___j2){ |j2, j| ({Sequel.qualify(j, :message_id) => Sequel.qualify(j2, :message_id)}) & (Sequel.qualify(j, :created_at) < Sequel.qualify(j2, :created_at))}.where(:j2__id => nil).select(:jobs__id)
    @valid_jobs = Job.dataset_with(
      :scalars => {
        :route => ['data', 'router', 'action']
      }
    ).where(
      :route => params[:namespace].to_s,
      :account_id => @account.id,
      :id => valid_jobs
    ).select(:id)
    @jobs_complete = Job.dataset_with_complete.where(
      :account_id => @account.id
    ).where('? = ANY(complete)', 'package_builder') #params[:namespace].to_s)
    @jobs_inprogress = Job.dataset_with_router.where(
      :account_id => @account.id
    ).where('? = ANY(router)', 'package_builder') #params[:namespace].to_s)
    @jobs_error = Job.dataset_with(
      :scalars => {
        :error => ['error', 'callback']
      }
    ).where("error like ?", "#{params[:namespace]}:%")
    if(params[:payload_filter])
      location = MultiJson.load(Base64.urlsafe_decode64(params[:payload_filter]))
      value = Base64.urlsafe_decode64(params[:payload_value])
      @jobs_inprogress = Job.dataset_with(
        :scalars => {
          :custom_search => location
        }
      ).where(:id => @jobs_inprogress.select(:id)).
        where(:custom_search => value)
      @jobs_complete = Job.dataset_with(
        :scalars => {
          :custom_search => location
        }
      ).where(:id => @jobs_complete.select(:id)).
        where(:custom_search => value)
    end
  end

  ## Need success and error counts
  # -> query for error payloads
  # -> subtract/remove from completed depending on view
  # -> need to add group by and squash so we showing jobs and not
  #counting history


  def all
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        complete_jobs = @jobs_complete.select(:id).all.map(&:id) + @jobs_inprogress.select(:id).all.map(&:id) + @jobs_error.select(:id).all.map(&:id)
        @jobs = Job.where(:id => @valid_jobs).order(:created_at.desc)
        @progress = (@jobs.map(&:percent_complete).sum.to_f / @jobs.count)
      end
    end
  end

end
