class ApplicationController < ActionController::Base
  protect_from_forgery

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_path, :alert => exception.message
	end

	# rescue_from ActionController::RoutingError do |exception|
	# 	flash[:error] = "Page not found"
	# 	redirect_to root_path
	# end

	def not_found
		raise ActionController::RoutingError.new('Not Found')
	end

end
