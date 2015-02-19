class Users::ConfirmationsController < Devise::ConfirmationsController
  protected

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource, :bypass => true)

    logger.debug("----- after_confirmation_path_for : #{resource}, #{resource.pending_intention}")
    if resource.pending_intention and resource.pending_intention[:pending_registration]
      logger.debug("----- after_confirmation_path_for 1")
      bitshares_account_path
    else
      logger.debug("----- after_confirmation_path_for 2")
      profile_path
    end
  end
end
