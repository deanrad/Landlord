require 'spec_helper'

describe Apartment do
  before(:all) do
    Apartment.setup do
      partition :floor,      :integer, :references => 'Floor#number'
      partition :direction,  :string,  :values => %w(E W) 
    end
    Apartment.tenants = [Page]
    Page.destroy_all
  end
  after(:each) do
    Apartment.current = nil
    Page.destroy_all
  end
  
  describe 'Valid Usage' do
    it 'should have one partition per partition defined in setup' do 
      Apartment.partitions.size.should == 2
    end
    it 'should require every partition to be specified when setting'
    it 'should validate data types' 
    it 'should validate data values'
    it 'should validate foreign key references'
  end
  
  describe 'its limiting effect on data' do
    it 'should limit the scope of \'all\'' do
      [1,2].each{ |i| Page.create(:floor => i, :direction => 'E') }
      
      Apartment.current = {:floor => 1, :direction => 'E'}
      Page.all.count.should == 1
      Apartment.current = nil
      Page.all.count.should == 2
      
      # Can also be written
      # Apartment.with(:floor => 1, :direction => 'E') do
      #   Page.all.count.should == 1
      # end
      # Apartment.with(nil) do
      #   Page.all.count.should == 2
      # end
    end
    
    it 'should allow further chaining of scopes'
    it 'should work with default scopes'
    it 'should work with STI'
    
  end
end