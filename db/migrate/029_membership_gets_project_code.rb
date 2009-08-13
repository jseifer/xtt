class MembershipGetsProjectCode < ActiveRecord::Migration
  def self.up
    add_column :memberships, :code, :string
    Membership.find(:all).each do |m|
      m.update_attribute :code, m.project.code
    end
    # remove project code
  end

  def self.down
    remove_column :memberships, :code
  end
end
