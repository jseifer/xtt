class PopulateLastStatus < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      if st = user.statuses.latest
        User.update_all ['last_status_id = ?, last_status_project_id = ?, last_status_at = ?, last_status_message = ?',
          st.id, st.project_id, st.created_at, st.message], ['id = ?', user.id]
      end
    end
  end

  def self.down
  end
end
