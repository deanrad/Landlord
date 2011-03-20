class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # you can do this where you want in the lifecycle, Dispatcher would be a good place, its 
  # only a filter to illustrate it should happen early
  prepend_before_filter :set_apartment
  def set_apartment
    apt = Apartment.from_request(request) 
    Apartment.current = apt
  rescue Apartment::InvalidError => ex
    # decide if you want stray request variables to possibly create errors
    logger.warn "Could not create valid apartment. Error was: #{ex.message}. Request:#{[request.host, request.path, request.params]}"
    raise "Suspected request tampering. Landlord says: Could not create valid Apartment."
  end
end
