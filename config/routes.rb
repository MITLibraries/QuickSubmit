Rails.application.routes.draw do
  resources :submissions, only: [:new, :create, :index]
  get 'submissions/package/:id', to: 'submissions#package', as: :submission_package
  post 'callbacks/status/:uuid', to: 'callbacks#status', as: :callback_submission_status

  devise_for :users, :controllers => {
    :omniauth_callbacks => 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :user_session
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'static#home'
  get 'static/home'
end
