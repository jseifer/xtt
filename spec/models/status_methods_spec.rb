require File.dirname(__FILE__) + '/../spec_helper'

[User, Project].each do |model|
  describe model, "#statuses" do
    define_models :statuses
  
    before do
      @record = send(model.table_name, :default)
    end
  
    describe User, "(order)" do
      define_models do
        model Status do
          stub :pending, :state => 'pending', :hours => 0, :created_at => current_time - 3.days
        end
      end
      
      it "retrieves associated statuses in reverse-chronological order" do
        @record.statuses.should == [statuses(:default), statuses(:pending)]
      end
    end
  
    it "retrieves status after given status" do
      @record.statuses.after(statuses(:default)).should == statuses(:pending)
    end
    
    it "retrieves status before given status" do
      @record.statuses.before(statuses(:pending)).should == statuses(:default)
    end
  end
end