class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :authenticate_user!, only: [:finish_signup]

  def profile
    @user = current_user
  end

  def bitshares_account
    @reg_status = nil
    @users = current_user

    if session[:pending_registration]
      reg = session[:pending_registration]
      do_register(reg['account_name'], reg['account_key'])
      session.delete(:pending_registration)
    end
    if params[:account]
      do_register(params[:account][:name], params[:account][:key])
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
          redirect_to profile_path, notice: 'We sent you a confirmation link. Please confirm your email'
        end
      end
    end
  end

  def subscribe
    new_status = !current_user.newsletter_subscribed
    subscription = current_user.subscribe(new_status)

    # todo: refactor this
    if subscription.is_a?(Hash)
      current_user.update_attribute(:newsletter_subscribed, new_status)
      render nothing: true
    else
      render json: { res: subscription }
    end
  end

  private

  def do_register(name, key)
    @reg_status = current_user.register_account(name, key, cookies[:_ref_account])
    if @reg_status[:error]
      flash[:alert] = "We were unable to register account '#{name}' - #{@reg_status[:error]}"
      @account = OpenStruct.new(name: name, key: key)
    end
  end
end
