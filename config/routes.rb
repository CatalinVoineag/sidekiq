Rails.application.routes.draw do

  root "products#index"

   get 'products/export_csv' => 'products#export_csv', as: :export_csv_file

end
