class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  respond_to :html, :json

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :email, :password, :password_confirmation) }
  end

  def after_sign_in_path_for(resource)
    if session[:pending_registration]
      bitshares_account_path
    else
      profile_path(resource)
    end
  end

  def after_log_in_path_for(resource)
    if session[:pending_registration]
      bitshares_account_path
    else
      profile_path(resource)
    end
  end

end
