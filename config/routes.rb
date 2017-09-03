Rails.application.routes.draw do

	require 'sidekiq/web'
	mount Sidekiq::Web => '/sidekiq'

  root "products#index"

  get 'products/export_csv' => 'products#export_csv', as: :export_csv_file

  # Job Tracker Routes
  get 'get_job_notifications', to: 'background_jobs#get_job_notifications'
  get 'get_job_progress/:job_id' => 'background_jobs#get_job_progress'
  delete 'delete_job' => 'background_jobs#delete_job'

end
