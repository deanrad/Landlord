require 'apartment'
Apartment.setup do
  partition :floor,      :integer, :references => 'Floor#number'
  partition :direction,  :string,  :values => %w(E W) 
  #partition :owner,      :integer, :references => 'Owner#id'
  #partition :published,  :boolean, :values => [true, false]
  #partition :visibility, :integer, :values => [1,2,3]
end

Apartment.tenants = [Page]
