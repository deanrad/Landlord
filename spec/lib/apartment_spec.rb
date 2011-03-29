require 'spec_helper'

describe Apartment do
  before(:each) do
    Apartment.setup do
      partition :floor,      :references => 'Floor#number'
      partition :direction,  :values => %w(E W), :allow_nil => true
    end
    Floor.find_or_create_by_number(1)
    Apartment.tenants = [Unit]
    Unit.destroy_all
  end
  after(:each) do
    Apartment.current = nil
    Unit.destroy_all
  end
  
  describe 'Valid Usage' do
    it 'should have one partition per partition defined in setup' do 
      Apartment.partitions.size.should == 2
    end
    it 'should require as many partitions as there are which dont allow nil' do
      lambda{
        Apartment.current = {:direction => 'W'} # floor is required
      }.should raise_error(Apartment::InvalidError)
      lambda{
        Apartment.current = {:floor => 1} # direction allows nil
      }.should_not raise_error(Apartment::InvalidError)
    end
    it 'should validate data values' do
      lambda{
        Apartment.current = {:floor => 1, :direction => 'QQ'}
      }.should raise_error(Apartment::InvalidError::ValueError)
    end
    it 'should validate foreign key references' do
      lambda{
        Apartment.current = {:floor => -1, :direction => 'E'}
      }.should raise_error(Apartment::InvalidError::ReferenceError)
    end
    describe 'tenants' do
      it 'should allow an explicit list' do
        t = [Unit]
        Apartment.tenants = t
        Apartment.tenants.should == t
      end
      it 'should allow :all_models' do
        Apartment.tenants = :all_models
        [Unit, Floor].each do |k|
          Apartment.tenants.should include(k)
        end
        Apartment.tenants = [Unit]
      end
    end
  end
  
  describe 'Apartment.current interface' do
    it 'should do sensible things with method missing' do
      Apartment.setup do
        partition :floor_id,   :references => 'Floor#number'
      end
      Apartment.current = {:floor_id => 1}
      Apartment.current_floor_id.should == 1
      Apartment.current_floor.should == Floor.find(1)
      
    end
  end
  
  describe 'Internals' do
    it 'should change the where_values_hash on the Thread local variable Model_scoped_methods' do
      Apartment.current = {:floor => 1}
      arel = Thread.current[:Unit_scoped_methods].first
      arel.should be_kind_of(ActiveRecord::Relation)
      arel.where_values_hash.should == {:floor => 1}
      arel.scope_for_create.should == {:floor => 1}
    end
  end
  
  describe 'its limiting effect on data' do
    before(:each) do
      [1,2].each{ |i| Unit.create(:title => "#{i}E", :floor => i, :direction => 'E') }
      Unit.create(:title => 'Floor 1 Whole Unit', :floor => 1) # no direction
      Unit.create(:title => '1W', :floor => 1, :direction => 'W')
    end
    after(:each) do
      Unit.destroy_all
    end
    it 'should limit the scope of \'all\'' do
      Apartment.with(:floor => 1, :direction => 'E') do
        Unit.all.count.should == 1
      end
      Apartment.with(nil) do
        Unit.all.count.should == 4
      end
    end
    
    it 'should remain in effect for a given thread' do
      # set it early in the request, process, etc... 
      Apartment.current = {:floor => 1, :direction => 'E'}
    
      # and it remains in effect
      Unit.all.count.should == 1

      # until turned off
      Apartment.current = nil
      Unit.all.count.should == 4
    end
    
    it 'should allow further chaining of scopes' do
      Apartment.current = {:floor => 1, :direction => 'W'}
      Unit.all.count.should == 1
      Unit.where(:title => '1W').count.should == 1
    end
    
    it 'should work with creating new records bound to that apartment' do 
      Apartment.with( :floor => 1, :direction => 'W') do
        p = Unit.create!(:title => 'Hi dere')
        [p.floor, p.direction].should == [1,'W']
      end
    end

    it 'should overwrite, not merge the old apartment' do 
      Apartment.current = {:floor => 1, :direction => 'W'}
      Apartment.current.size.should == 2

      Apartment.current = {:floor => 1}
      Apartment.current.size.should == 1
    end

    it 'should be turn-offable at the programmers discretion' do
      unscoped_unit_count = Apartment.with(nil){ Unit.all.count }
      Apartment.current = {:floor => 1}
      Unit.all.count.should < unscoped_unit_count
      # unscoped is a native ActiveRecord facility
      Unit.unscoped{ Unit.all.count }.should == unscoped_unit_count
    end
    
    it 'should work with default scopes' # yes, but Landlord will clobber keys of the default scope which overlap
    it 'should work with STI'
    it 'should work with habtm'
    it 'should work with has_many_through'
    
  end
end