ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'users', :action => 'index'

  map.resources :statuses

  map.resources :projects do |project|
    project.resources :statuses, :controller => 'project_statuses'
  end

  map.resources :groups do |group|
    group.resources :projects, :controller => 'group_projects'
    group.resources :statuses, :controller => 'group_statuses'
  end
  
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete }
  map.resource :session, :settings

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
end
