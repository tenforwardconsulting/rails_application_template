class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def admin_signed_in?
    current_user.try :admin?
  end
  helper_method :admin_signed_in?

  def require_admin
    render_not_authorized unless admin_signed_in?
  end

  def render_not_authorized
    flash[:alert] = 'Not authorized'
    if request.referrer
      #Rollbar.error "User clicked a link that shouldn't have been visible to them. Fix this."
      redirect_to request.referrer
    elsif current_user
      redirect_to after_sign_in_path_for(current_user)
    else
      redirect_to root_path
    end
  end
end
