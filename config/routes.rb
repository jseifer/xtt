ActionController::Routing::Routes.draw do |map|
  status_filters = /weekly|bi-weekly|monthly|daily|bi\-weekly/

  map.root :controller => 'users', :action => 'index'

  map.resources :statuses
  map.resources :projects, :member => {:invite => :post}
  
  map.filtered_user 'users/:id/:filter', :filter => status_filters, :controller => 'users', :action => 'show'
  
  map.with_options :controller => 'projects', :action => 'show' do |project|
    project.project_for_all  'projects/:id/all'
    project.project_for_me   'projects/:id/:user_id', :user_id => /me/
    project.project_for_user 'projects/:id/users/:user_id'
    project.filtered_project_for_all  'projects/:id/all/:filter', :filter => status_filters
    project.filtered_project_for_me   'projects/:id/:user_id/:filter', :user_id => /me/, :filter => status_filters
    project.filtered_project_for_user 'projects/:id/users/:user_id/:filter', :filter => status_filters
  end
  
  map.resources :feeds # todo: move to projects
  
  map.resources :memberships  
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete }

  map.filtered_user 'users/:id/:filter', :filter => status_filters, :controller => 'users', :action => 'show'

  map.resource :session, :settings

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.invite   '/invitations/:code',         :controller => 'users',    :action => 'invite'
  map.connect  '/invitations',               :controller => 'sessions', :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
end
