Rails.application.routes.draw do
  scope '(:locale)', constraints: { locale: /ru|en/ } do
    namespace :admin do
      resources :regions, only: [:index, :show] do
        member do
          post 'priority', defaults: { format: :json }
          post 'toggle', defaults: { format: :json }
          put 'lock', defaults: { format: :json }
          delete 'lock', action: :unlock, defaults: { format: :json }
        end
      end

      # get 'privileges/:id/regions' => 'privileges#regions', as: :regions_admin_privilege, defaults: { format: :json }
    end

    resources :regions, except: [:update, :destroy] do
      member do
        get 'children', defaults: { format: :json }
      end
    end
  end

  resources :regions, only: [:update, :destroy]
end
