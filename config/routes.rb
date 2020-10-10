require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "graphql#execute"
  end
  post '/graphql', to: 'graphql#execute'

  namespace 'api' do
    namespace 'v1' do
      resources :activities, only: [:index]
      resources :locations, only: [:index]
    end
  end
end
