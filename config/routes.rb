Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	namespace :admin do
    root 'page#index'
	  get 'no_access_right', controller: :page, action: :no_access_right
	  match 'login', controller: :page, action: :login, via: [:get, :post]
	  get 'logout', controller: :page, action: :logout
  end

  scope module: :front do
  	root 'page#index'
  end
end
