Kietter::Application.routes.draw do
  root :to => 'home#index'
  match '/auth/:provider' => 'sessions#error'
  match '/investigate' => 'home#investigate'
  match '/auth/:provider/callback' => 'session#callback'
  match '/logout' => 'session#destroy'

end
