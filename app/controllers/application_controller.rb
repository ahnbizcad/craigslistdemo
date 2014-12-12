class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
 
  protected
   
  # Devise strong parameters
  def configure_permitted_parameters
    #devise_parameter_sanitizer.for(:sign_up) << :username
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password) }
  end

  def currently_admin?
    if user_signed_in?
      current_user.admin? ? true : false
    else
      false
    end
  end
  helper_method :currently_admin?

  def authorize_admin
    redirect_to root_path, alert: 'Sorry, Admins only' unless current_user.admin?
  end
  helper_method :authorize_admin 

end
