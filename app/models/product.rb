class Product < ActiveRecord::Base

  def self.download_csv(tracker_id)
    counter = 0
    products = Product.all
    job = JobTracker.where(id: tracker_id).first
    
    csv_string = CSV.generate do |csv|
      products.each do |product|
        csv << [product.title, product.price]
        
        counter += 1
        job.progress_max = products.count if job.progress_max == 0
        job.progress_current = counter
        job.save!  
      end
    end
    return csv_string
  end

end