Rails.application.routes.draw do

  root 'home#index'

  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'logins' }

  devise_scope :user do
    get 'registrations/ok' => 'registrations#ok'
    get 'registration/reauth' => 'registrations#reauth'
    post 'registration/reauth' => 'registrations#reauth_do'
    get 'logins/ok' => 'logins#ok'
    post 'logins/new' => 'logins#new_pn'
  end

  get 'sessions/:id'  => 'sessions#show'
  put 'sessions/:ssid/register' => 'sessions#update_registrations'
  put 'sessions/:ssid/login' => 'sessions#update_logins'
  put 'sessions/certification' => 'sessions#update_certifications'
  post 'sessions/verify' => 'sessions#verify'

end
