class Profile::ReferralCodesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_referral, :only => [:edit, :update, :show, :destroy, :send_mail]

  helper_method :sort_column, :sort_direction

  def index
    @q = ReferralCode.search(params[:q])
    @referrals = find_referrals
  end

  def create
    @referral = ReferralCode.new(referral_code_params) do |r|
      r.user_id = current_user.id
      r.code = ReferralCode.generate_code
      r.amount *= r.asset.precision if r.amount
    end

    if @referral.save
      redirect_to profile_referral_code_path(@referral), :notice => I18n.t('referral_codes.successfully_created')
    else
      @user = current_user
      render 'users/profile'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @referral.update_attributes(referral_code_params)
      redirect_to admin_referral_codes_path, :notice => I18n.t('referral_codes.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @referral.destroy
    redirect_to admin_referral_codes_path, :notice => "Referral code deleted."
  end

  def send_mail
    if ReferralRegistrator.new(current_user, @referral, params[:email]).send_mail
      redirect_to profile_path, notice: 'Email sent'
    else
      # todo: add exception message
      render :show, alert: 'Error occurred, try again'
    end
  end

  protected

  def find_referral
    @referral = ReferralCode.find(params[:id])
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
