class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  respond_to :html, :json

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :assign_uid

  def authenticate_admin_user!
    raise ActiveRecord::RecordNotFound unless current_user and current_user.is_admin
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      if session[:pending_registration]
        bitshares_account_path
      else
        profile_path
      end
    else
      finish_signup_path(resource)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :email, :password, :password_confirmation) }
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
    return unless current_user

    if cookies[:_uid_]
      @uid = cookies[:_uid_]
    else
      @uid = SecureRandom.urlsafe_base64(16)
      cookies[:_uid_] = {
          value: @uid,
          expires: 10.years.from_now,
          domain: request_domain()
      }
    end

    current_user.update_attribute(:uid, @uid) unless current_user.uid == @uid
  end

end
