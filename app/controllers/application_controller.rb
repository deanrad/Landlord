class ApplicationController < ActionController::Base
  include Apartment::ControllerDetection
  protect_from_forgery
end
