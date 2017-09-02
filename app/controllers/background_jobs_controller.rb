class BackgroundJobsController < ApplicationController

	def get_job_notifications
    user_id = params[:user_id]
    @jobs = JobTracker.not_processing_or_enqueued user_id
    keep_asking = @jobs_count > 0

    @jobs.each do |job|
      msg = job.status == "Complete" ? job.title + " completed" : job.title + " failed"
      type = job.reference_record + job.reference_type
    end

    if @jobs.count > 0
      @jobs.update_all(notified: true)
    end

    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render :json => {jobs: @jobs, keep_asking: keep_asking}, methods: [:alert], status: :ok }
      format.json { render :json => {jobs: @jobs, keep_asking: keep_asking}, methods: [:alert], status: :ok }
    end
  end

  ## error should pass
  def error
    @job = JobTracker.where(job_id: params[:id], depot_id: Depot.current).first
    if @job.present?

    else
      redirect_to root_path, alert: "The Job you were looking for not found or no longer exist"
    end
  end

  def delete_job
    job_id = params[:id]


    job = JobTracker.find(job_id)
  
    respond_to do |format|
      if !job.blank? && job.destroy
        # job.stop_worker_and_remove_alert
        flash.now[:alert] = "Job deleted successfully"
        format.html { redirect_to root_path }
        format.js { render :json => {message: "job destroyed successfully"}, status: :ok }
        format.json { render :json => {message: "job destroyed successfully"}, status: :ok }
      else
        flash.now[:error] = "Could not delete job"
        format.html { redirect_to root_path }
        format.js { render :json => {message: "job destroyed successfully"}, status: :ok }
        format.json { render :json => {message: "job destroyed successfully"}, status: :ok }
      end
    end
  end

	def get_job_progress
		job_id = params[:job_id]

		@job = JobTracker.find(job_id)
    if @job.present?
      percentage = !@job.progress_max.zero? ? @job.progress_current / @job.progress_max.to_f * 100 : 0
      render json: @job.attributes.merge!(percentage: percentage).to_json
    else
	    render json: ''
	  end
	end

end
