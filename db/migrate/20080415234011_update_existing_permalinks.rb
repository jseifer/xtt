class UpdateExistingPermalinks < ActiveRecord::Migration
  class User    < ActiveRecord::Base; end
  class Project < ActiveRecord::Base; end
  class Context < ActiveRecord::Base; end

  def self.up
    say_with_time "Updating user permalinks..." do
      transaction do
        User.paginated_each do |user|
          User.update_all ['permalink = ?', PermalinkFu.escape(user.login)], ['id = ?', user.id]
        end
      end
    end

    say_with_time "Updating project permalinks..." do
      transaction do
        Project.paginated_each do |project|
          Project.update_all ['permalink = ?', PermalinkFu.escape(project.name)], ['id = ?', project.id]
        end
      end
    end

    say_with_time "Updating context permalinks..." do
      transaction do
        Context.paginated_each do |ctx|
          Context.update_all ['permalink = ?', PermalinkFu.escape(ctx.name)], ['id = ?', ctx.id]
        end
      end
    end
  end

  def self.down
  end
end
