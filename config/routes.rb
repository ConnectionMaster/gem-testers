GemTesters::Application.routes.draw do
  root :to => 'rubygems#index'

  resources :rubygems, path: 'gems' do
    constraints id: Rubygem::ROUTE_MATCHER do
      get '/feed' => 'rubygems#feed', as: 'feed', format: :xml
      get '/paged.:format' => 'rubygems#show_paged', as: 'paged'
      get '/charts' => 'rubygems#charts', as: 'charts'
      resources :versions, path: 'v' do
        get '/paged' => 'versions#show_paged', as: 'paged', format: :json
        get '/:id' => "versions#show", as: 'show', format: [:html, :json]
        resources :test_results 
      end
    end
  end

  resource :author, controller: :authors do
    get ':id/gems' => 'authors#gems', as: 'gems', format: [:html]
  end

  get '/browse'         => 'browse#index',    as: 'browse_index',   format: [:html]
  get '/browse/gems'    => 'browse#gems',     as: 'browse_gems',    format: [:html]
  get '/browse/authors' => 'browse#authors',  as: 'browse_authors', format: [:html]

  post '/test_results' => 'test_results#create'
  get '/test_results.:format' => 'test_results#index', as: 'test_results'
end
