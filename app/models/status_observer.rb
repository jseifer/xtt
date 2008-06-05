class StatusObserver < ActiveRecord::Observer

  def after_create(status)
    Bj.submit %{/usr/bin/env rake tt:notify STATUS=#{status.id}}, :rails_env => RAILS_ENV, :tag => "notifies"
  end

end