class ProductsController < ApplicationController

  def index
    @products = Product.all
    @jobs = JobTracker.all
  end

  def export_csv
	  options = { queue: "export_csv", reference_type: "Product", title: "CSV Export"}
	  
    ExportCsvWorker.perform_async(options)
    redirect_to root_path
  end

end


