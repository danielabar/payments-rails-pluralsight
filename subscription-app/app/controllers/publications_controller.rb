class PublicationsController < ApplicationController
  before_action :check_subscription, only: [:show]

  def index
    @publications = Publication.all
  end

  def show
    @publication = Publication.find(params[:id])
  end

  def check_subscription
    unless user_signed_in? && current_user.subscription.active
      redirect_to publications_path, alert: "You must be a subscriber to view this content."
    end
  end
end