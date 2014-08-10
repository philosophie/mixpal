Rails.application.routes.draw do
  root to: 'redirects#new'
  get :to_root, to: 'redirects#to_root'
end
