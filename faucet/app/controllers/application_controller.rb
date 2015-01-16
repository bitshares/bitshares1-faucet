class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  respond_to :html, :json

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :assign_uid


  def authenticate_admin_user!
    raise ActiveRecord::RecordNotFound if not (current_user and current_user.is_admin)
  end

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

  def request_domain
    host = URI.parse(request.original_url).host
    host = $1 if host =~ /(\w+\.\w+)\z/
    return host
  end

  def write_referral_cookie(r)
    cookies[:_ref_account] = {
        value: r,
        expires: 1.month.from_now,
        domain: request_domain()
    }
  end

  private

  def assign_uid
    @uid = cookies[:_uid_]
    if @uid
      current_user.update_attribute(:uid, @uid) if current_user and current_user.uid != @uid
      return
    end
    @uid = SecureRandom.urlsafe_base64(16)
    cookies[:_uid_] = {
        value: @uid,
        expires: 10.years.from_now,
        domain: request_domain()
    }
    current_user.update_attribute(:uid, @uid) if current_user and current_user.uid != @uid
  end

end
