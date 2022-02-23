Rails.application.routes.draw do
  root 'items#index'
  resources :items, only: %i[index new create]
end
