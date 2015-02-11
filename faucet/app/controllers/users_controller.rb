class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :authenticate_user!, only: [:finish_signup]

  def profile
    @user = current_user
  end

  def bitshares_account
    @reg_status = nil
    @subscription_status = current_user.newsletter_subscribed

    if session[:pending_registration]
      reg = session[:pending_registration]
      do_register(reg['account_name'], reg['account_key'], reg['owner_key'])
      session.delete(:pending_registration)
    end
    if params[:account]
      do_register(params[:account][:name], params[:account][:key], nil)
    end
  end

  def finish_signup
    user = User.find(params[:id])

    if user.email_verified? && user.confirmed_at
      redirect_to root_path, notice: 'You have already confirmed your email.'
    else
      if request.patch? && params[:user] && params[:user][:email]
        if user.update_attribute(:email, params[:user][:email])
          sign_in(user, :bypass => true)
          redirect_to profile_path, notice: "We've sent you a confirmation link."
        end
      end
    end
  end

  def subscribe
    new_status = !current_user.newsletter_subscribed
    status = params[:status] == new_status ? params[:status] : new_status
    subscription = current_user.subscribe(status)

    if subscription.is_a?(Hash)
      current_user.update_attribute(:newsletter_subscribed, status)
      render json: {res: render_to_string('_subscribe', layout: false, locals: {status: status})}
    else
      render json: {res: subscription.to_s}
    end
  end

  private

  def do_register(name, key, owner_key)
    @reg_status = current_user.register_account(name, key, owner_key, cookies[:_ref_account])
    if @reg_status[:error]
      flash[:alert] = "We were unable to register account '#{name}' - #{@reg_status[:error]}"
      @account = OpenStruct.new(name: name, key: key, owner_key: owner_key)
    end
  end
end
