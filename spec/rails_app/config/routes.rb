Rails.application.routes.draw do
  # Resources for testing
  root to: "home#index", via: [:get, :post]
end
