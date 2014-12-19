class WelcomeController < ApplicationController

  def index
    if params[:account_name] and params[:account_key]
      session[:pending_registration] = {account_name: params[:account_name], account_key: params[:account_key]}
      redirect_to bitshares_account_path if user_signed_in?
    end
  end

end
