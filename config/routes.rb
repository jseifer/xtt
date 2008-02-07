ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'users', :action => 'index'

  map.resources :statuses
  map.resources :projects, :member => {:invite => :post}
  
  map.with_options :controller => 'projects', :action => 'show' do |project|
    project.project_for_all  'projects/:id/all'
    project.project_for_me   'projects/:id/:user_id', :user_id => /me/
    project.project_for_user 'projects/:id/users/:user_id'
    project.filtered_project_for_all  'projects/:id/all/:filter', :filter => /weekly|bi-weekly|monthly|daily|bi\-weekly/
    project.filtered_project_for_me   'projects/:id/:user_id/:filter', :user_id => /me/, :filter => /weekly|bi-weekly|monthly|daily|bi\-weekly/
    project.filtered_project_for_user 'projects/:id/users/:user_id/:filter', :filter => /weekly|bi-weekly|monthly|daily|bi\-weekly/
  end
  
  map.resources :feeds # todo: move to projects
  
  map.resources :memberships  
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete }
  map.resource :session, :settings

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
end
