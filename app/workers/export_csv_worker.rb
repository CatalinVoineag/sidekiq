require "sidekiq/api"

class ExportFormWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers
  class AlreadyProcessingException < StandardError; end
  sidekiq_options :queue => "export_csv", :retry => false, :backtrace => true

  MINLINECOUNT = 100


  def perform(options)
    return if cancelled?
    
    begin
      @tracker = JobTracker.where(job_id: self.jid).first
      unless @tracker.present?
        @tracker = JobTracker.new
      # else
      #   raise AlreadyProcessingException.new("This task is already under processing") if @tracker.status == JobTracker::PROCESSING
      end
      options = {queue: queue, reference_id: record_id,
                 depot_id: depot_id, reference_type: model, reference_record: record_name,
                 user_id: user_id, title: title, link_text: link_text, job_id: job_id,
                 status: JobTracker::ENQUEUED}
      @tracker.assign_attributes(options)

      @tracker.save!
      lock = SystemLockControl.new
      lock.synchronize('depot_lock_' + depot_id.to_s + "_" + model.underscore) do
        @tracker.reload
        @tracker.update_attributes(status: JobTracker::PROCESSING)
        export_form = ExportForm.find(record_id)
        obj_rel = eval(model).unscoped.find(obj_ids)

        if export_form.column_headers
          csv = export_form.download_column_headers(required_pairs, obj_rel, @tracker.id)
        else
          # we need to have better numericality position validation for export format
          position_order = required_pairs.values.sort_by { |x| x[/\d+/].to_i }
          csv = export_form.download_column_position(required_pairs, obj_rel, position_order, @tracker.id)
        end
        if Rails.env.production?
          absolute_path = "/home/deploy/apps/prosku/shared/tmp/"
        else
          absolute_path = "tmp/"
        end

        File.open(absolute_path + title.gsub(" ", "_").downcase + "_" + self.jid.to_s + ".csv", 'w') { |f| f.write(csv) }
        @tracker.status = "Complete"
        @tracker.redirect_link = company_download_csv_background_path(company_id, record_id, link: title.gsub(" ", "_").downcase + "_" + job_id + ".csv", format: "csv")
        @tracker.save!
      end
  

  end


  def cancelled?
    Sidekiq.redis { |c| c.exists("cancelled-#{jid}") }
  end

  def self.cancel!(jid)
    Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 86400, 1) }
  end


end