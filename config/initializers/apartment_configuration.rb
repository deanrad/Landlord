require 'apartment'
Apartment.setup do
  partition :floor,      :references => 'Floor#number', 
                         :allow_nil => false,
                         :http_initializer => lambda{ |req| 
                            req.params[:floor] || (req.host =~ /floor(\d)\..*/; $1) || 1 
                          }
                            
                         
  partition :direction,  :values => %w(E W), 
                         :allow_nil => true
  #partition :owner,      :references => 'Owner#id'
  #partition :published,  :values => [true, false]
  #partition :visibility, :values => [1,2,3]
end

Apartment.tenants = :all_models
Apartment.tenants -= [Floor]
