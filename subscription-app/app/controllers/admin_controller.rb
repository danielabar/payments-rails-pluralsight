class AdminController < ApplicationController
  before_filter :check_for_admin

  def check_for_admin
    if currnet_user.nil? || !current_user.is_admin?
      redirect_to root_path, alert: "You must be an admin to access this path."
    end
  end
end