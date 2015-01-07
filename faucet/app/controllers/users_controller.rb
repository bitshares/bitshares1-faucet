class UsersController < ApplicationController

  before_action :authenticate_user!

  def profile
    @user = current_user
  end

  def bitshares_account
    @reg_status = nil
    if session[:pending_registration]
      reg = session[:pending_registration]
      do_register(reg['account_name'], reg['account_key'])
      session.delete(:pending_registration)
    end
    if params[:account]
      do_register(params[:account][:name], params[:account][:key])
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
