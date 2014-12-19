class Admin::BaseController < ApplicationController

  before_filter :require_admin

  protected

  def require_admin
    unless current_user.is_admin
      render404 and return false
    end
  end

  def render404
    render :file => File.join(Rails.root, 'public', '404.html'), :status => 404
    return true
  end

end
