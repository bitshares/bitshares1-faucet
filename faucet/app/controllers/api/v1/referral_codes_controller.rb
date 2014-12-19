module Api
  module V1
    class ReferralCodesController < Api::BaseController

      def show
        @referral = ReferralCode.where(code: params[:id]).first
        @referral = ReferralCode.new unless @referral
      end

      def redeem
        @referral = ReferralCode.where(code: params[:referral_code_id]).first
        @referral = ReferralCode.new unless @referral
        @referral.redeem(params[:account_name], params[:account_key])
        render action: 'show'
      end

    end
  end
end
