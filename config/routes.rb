RailsWeddingRsvp::Application.routes.draw do
  authenticated :user do
    root :to => 'invitations#index'
  end

devise_for :users, :skip => [:sessions, :registrations]
as :user do
	get 'login' => 'devise/sessions#new', :as => :new_user_session
	post 'login' => 'devise/sessions#create', :as => :user_session
	delete 'logout' => 'devise/sessions#destroy', :as => :destroy_user_session
	# get 'register' => 'devise/registrations#new', :as => :new_user_registration
	# post 'register' => 'devise/registrations#create', :as => :user_registration
	get 'profile' => 'devise/registrations#edit', :as => :edit_user_registration
	put 'register' => 'devise/registrations#update', :as => :user_registration
end

resources :users
resources :invitations do |invitation|
	resources :invitees, :except => [:index, :show, :new]
end

get 'invitations', :to => 'invitations#index', :as => :user_root
get 'invitations/:id/deliver' => 'invitations#deliver', :as => :deliver_invitation
put 'email_multiple' => 'invitations#email_multiple', :as => :email_multiple_invitations
get 'invitations/:id/remind' => 'invitations#remind', :as => :remind_invitation
match 'lookup' => 'invitations#lookup', :as => :lookup_invitation, :via => [:get, :post]
get 'i/:code' => 'invitations#view', :as => :view_invitation
get 'rsvp/:code' => 'invitations#rsvp', :as => :rsvp
put 'rsvp/:code' => 'invitations#rsvp', :as => :rsvp
get 'thanks/:code' => 'invitations#thanks', :as => :rsvp_thanks
get 'track/:code' => 'invitations#track', :as => :track_invitation
get '/phone/receive' => 'twilio#receive', :as => :twilio_receive_call
post '/phone/retrieve_invitation' => 'twilio#retrieve_invitation', :as => :twilio_retrieve_invitation
# get '/phone/retrieve_invitation/:code' => 'twilio#retrieve_invitation', :as => :twilio_retrieve_invitation
post '/phone/set_invitee_attendance/:code/:invitee_id' => 'twilio#set_invitee_attendance', :as => :twilio_set_invitee_attendance

root :to => "invitations#lookup"

end