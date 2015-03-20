class Profile::ReferralCodesController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :authenticate_user!, only: [:referral_login]
  before_action :find_referral, :only => [:edit, :update, :show, :destroy, :send_mail]

  helper_method :sort_column, :sort_direction

  def index
    @q = ReferralCode.where(user_id: current_user.id).search(params[:q])
    @referrals = find_referrals
    @referral = ReferralCode.new
  end

  def create
    @referral = ReferralCode.new(referral_code_params) do |r|
      r.user_id = current_user.id
      r.code = ReferralCode.generate_code
      r.amount *= r.asset.precision if r.amount
      r.expires_at = r.mutate_expires_at(params[:referral_code][:expires_at])
    end

    if @referral.save
      redirect_to profile_referral_code_path(@referral)
    else
      @user = current_user
      render 'users/profile'
    end
  end

  def show
  end

  #def edit
  #end

  def update
    if @referral.update_attributes(referral_code_params)
      redirect_to admin_referral_codes_path, :notice => I18n.t('referral_codes.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @referral.funded?
      ReferralCodesUpdater.refund(@referral)
      @referral.destroy
      redirect_to profile_referral_codes_path, :notice => "Referral code deleted and refunded"
    else
      @referral.destroy
      redirect_to profile_referral_codes_path, :notice => "Referral code was deleted."
    end
  rescue ReferralCodesUpdater::FundedByNotSet
    redirect_to profile_referral_codes_path, :alert => "Referral code was not deleted."
  end

  def send_mail
    result = ReferralRegistrator.new(@referral, params[:email]).send_referral_mail

    if result.is_a?(Hash) && result[:error]
      flash[:error] = result[:error]
      render :show
    else
      redirect_to profile_path, notice: 'Email sent'
    end
  end

  def referral_login
    result = ReferralAuthenticator.new(params[:login_hash], params[:email]).login

    if result.is_a?(Hash) && result[:error]
      redirect_to root_path, alert: result[:error]
    else
      sign_in(:user, result)
      redirect_to profile_referral_code_path(params[:code_id])
    end
  end

  def redeem
    account_name = params[:account]
    redirect_to :back, alert: 'Please provide account name.' unless account_name.present?

    # TODO: check if account name is registered on the blockchain (will do it myself later)

    referral = ReferralCode.where(aasm_state: [:sent, :funded])

    if params[:code]
      referral = referral.where(code: params[:code]).first
    else
      referral = referral.where(sent_to: current_user.email).first
    end

    if referral
      res = ReferralCodesUpdater.redeem(referral, account_name)
      if res[:error]
        logger.error("!!! Error in ReferralCodesUpdater.redeem: #{res[:error]}")
        redirect_to :back, alert: "We couldn't make a transfer at this time. This issue will be reported to website admins. Please try again later."
      else
        redirect_to profile_path, notice: "Your account was credited with #{referral.amount/referral.asset.precision} #{referral.asset.symbol}"
      end
    else
      redirect_to :back, alert: 'Referral code not found. Please make sure you entered correct code.'
    end
  end

  protected

  def find_referral
    @referral = ReferralCode.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @referral.user == current_user || @referral.user_is_receiver?(current_user) && !@referral.expired?
  end

  def find_referrals
    search_relation = @q.result
    @referrals = search_relation.order(sort_column + " " + sort_direction).references(:referral_code).page params[:page]
  end

  def sort_column
    ReferralCode.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  private

  def referral_code_params
    params.require(:referral_code).permit(:code, :expires_at, :redeemed_at, :account_name, :amount, :ref_code_id, :asset, :asset_id)
  end

end
