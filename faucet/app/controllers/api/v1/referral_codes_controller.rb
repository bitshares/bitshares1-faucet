module Api
  module V1
    class ReferralCodesController < Api::BaseController

      def show
        @referral = ReferralCode.where(code: params[:id]).first || ReferralCode.new
      end

      def redeem
        @referral = ReferralCode.where(code: params[:referral_code_id]).first || ReferralCode.new
        @referral.redeem(params[:account_name], params[:account_key] || params[:active_key])
        render action: 'show'
      end

    end
  end
end
