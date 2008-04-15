class Tendril < ActiveRecord::Base
  belongs_to :notifies, :polymorphic => true
  belongs_to :project

end
