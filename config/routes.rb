Rails.application.routes.draw do

  namespace :v1 do
    resources :item_types, only: :index
    resources :reservations, except: [:new, :edit] do
      member { post :update_item }
    end
  end
end
