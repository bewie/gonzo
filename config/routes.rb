Gonzo::Application.routes.draw do

  root 'hosts#index'
  resources :hosts, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ } do
    resources :products do
      resources :releases, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }
    end
  end
  resources :releases, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ } do
    member do
      get 'check'
      get 'summary'
      resources :changes, only: :show
      resources :tiers, only: :show
    end
  end
  resources :products do
    resources :releases, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }
  end

  # get "nodes" => 'nodes#index'
  resources :nodes, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }
  resources :agents, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }

  namespace :api do
    resources :agents, only: [:index], defaults: {format: :json}
    namespace :v1 do
      resources :releases, :constraints => { :id => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ } do
        member do
          put 'check'
          get 'summary'
        end
        collection do
          put 'refresh'
        end
      end
    end
  end

  mount Resque::Server.new, :at => "/resque"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
