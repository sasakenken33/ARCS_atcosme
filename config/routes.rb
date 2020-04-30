Rails.application.routes.draw do
  get '/', to: 'reviews#top'
  get "/reviews/download", to: "reviews#download"
  post 'reviews/scrape', to: "reviews#scrape"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
