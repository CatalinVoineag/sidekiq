require "sidekiq/api"
require 'csv'
class ExportCsvWorker

  include Sidekiq::Worker
  include Rails.application.routes.url_helpers
  sidekiq_options :queue => "export_csv", :retry => false, :backtrace => true

  MINLINECOUNT = 100

  def perform(options)
    queue = options["queue"]
    model = options["model"]
    title = options["title"]
    job_id = self.jid
    begin
      @tracker = JobTracker.where(job_id: self.jid).first
      unless @tracker.present?
        @tracker = JobTracker.new
      end

      options = { queue: queue, reference_type: model, title: title, job_id: job_id,
                 status: JobTracker::PROCESSING }
      @tracker.assign_attributes(options)

      @tracker.save!  

      csv = Product.download_csv(@tracker.id)

      file_name = "export_" + Time.zone.now.to_s + ".csv"

      File.open('public/export_' + Time.zone.now.to_s + '.csv' , 'w') { |f| f.write(csv) }
      @tracker.update_attributes(status: JobTracker::COMPLETE, redirect_link: file_name)
    rescue Exception => ex
      logger.info ex.message
    end
  end


  def cancelled?
    Sidekiq.redis { |c| c.exists("cancelled-#{jid}") }
  end

  def self.cancel!(jid)
    Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 86400, 1) }
  end

end
