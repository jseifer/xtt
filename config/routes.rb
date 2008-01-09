ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'users', :action => 'index'

  map.resources :statuses, :projects
  map.resources :groups, :has_many => [:statuses, :projects]
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete },
                        :has_many => [:statuses, :projects]
  map.resource :session, :settings

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
end
