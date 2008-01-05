ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'users', :action => 'index'

  map.resources :statuses, :projects
  map.resources :users, :has_many => :statuses
  map.resource :session
  
  map.project_statuses_path 'projects/:project_id/statuses', :controller => 'statuses', :action => 'index'

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
end
