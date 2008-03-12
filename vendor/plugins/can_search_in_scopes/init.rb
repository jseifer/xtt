# I has an inspiration
#
#   class Hit
#     can_search do
#       scoped_by :users, :scope => :reference
#       scoped_by :created, :attribute => :created_at, :scope => :date_range
#       scoped_by :published, :attribute => :published_at, :scope => :date_range
#       date_filter :annually do |now|
#         whatever
#       end
#     end
#   end
# 
class << ActiveRecord::Base
  def can_search(&block)
    self.search_scopes = CanSearchInScopes::SearchScopes.new(self, &block)
  end
end