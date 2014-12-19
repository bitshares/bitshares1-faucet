class UsersController < ApplicationController

  before_action :authenticate_user!

  def profile
    @user = current_user
  end

  def bitshares_account
    @reg_status = nil
    if session[:pending_registration]
      reg = session[:pending_registration]
      @reg_status = current_user.register_account(reg['account_name'], reg['account_key'])
      if @reg_status[:error]
        flash[:alert] = "We were unable to register account '#{reg['account_name']}' - #{@reg_status[:error]}"
      end
      session.delete(:pending_registration)
    end
  end

end
