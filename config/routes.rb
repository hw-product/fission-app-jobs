Rails.application.routes.draw do

  resources :jobs, :only => [:index, :show]

  resources :accounts do
    resources :jobs, :only => [:index, :show]
  end

end
