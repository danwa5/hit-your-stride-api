require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace 'api' do
    namespace 'v1' do
      resources :activities, only: [:index]
    end
  end
end
