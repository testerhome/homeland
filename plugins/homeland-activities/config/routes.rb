Homeland::Activities::Engine.routes.draw do
  #resources :comments

  namespace :admin do
    resources :events do
      member do
        post :suggest
        post :unsuggest

        post :publish
        post :failure
      end
    end
  end
  resources :events
end
