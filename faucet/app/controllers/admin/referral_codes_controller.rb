class Admin::ReferralCodesController < Admin::BaseController

  helper_method :sort_column, :sort_direction

  before_filter :find_referral, :only => [:edit, :update, :show, :destroy]

  def index
    @q = ReferralCode.search(params[:q])
    @referrals = find_referrals
  end


  def new
    @referral = ReferralCode.new
  end

  def create
    @referral = ReferralCode.new(referral_code_params)
    if @referral.save
      redirect_to admin_referral_code_path(@referral), :notice => "Successfully created referral code."
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @referral.update_attributes(referral_code_params)
      redirect_to admin_referral_codes_path, :notice => "Successfully updated referral code."
    else
      render :edit
    end
  end

  def destroy
    @referral.destroy
    redirect_to admin_referral_codes_path, :notice => "Referral code deleted."
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
