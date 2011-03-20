require 'apartment'
Apartment.setup do
  partition :floor,      :references => 'Floor#number',  
                         :request_proc => lambda{|req| req.params[:floor]}
                         
  partition :direction,  :values => %w(E W), 
                         :allow_nil => true
  #partition :owner,      :references => 'Owner#id'
  #partition :published,  :values => [true, false]
  #partition :visibility, :values => [1,2,3]
end

Apartment.tenants = [Page] # :all_models
