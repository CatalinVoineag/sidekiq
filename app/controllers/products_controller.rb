class ProductsController < ApplicationController

  def index
    @products = Product.all
  end

  def export_csv
  	 
     options = { depot_id: Depot.current, record_id: @export_form.id, record_name: @export_form.class.name, model: @export_form.model, company_id: @export_form.company_id, queue: 'export_csv', priority: 0, obj_ids: obj_ids, required_pairs: required_pairs, user_id: User.current, title: title} 
     ExportFormWorker.perform_async(options)
     
     flash[:notice] = "Processing Job. Please wait"
     redirect_to background_jobs_path
  end

end
