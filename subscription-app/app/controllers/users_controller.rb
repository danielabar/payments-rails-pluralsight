class UsersController < ApplicationController
  before_action :authenticate_user!

  # TODO: checkout_session_controller.rb will also redirect here if user cancel's, handle that as well
  def info
    stripe_session_id = params[:session_id]
    if stripe_session_id
      puts "Redirected here from Stripe subscription signup: #{stripe_session_id}"
      stripe_session = Stripe::Checkout::Session.retrieve(stripe_session_id)
      # TODO: verify "payment_status": "paid" and "status": "complete" from stripe_session
      current_user.subscription.update(
        stripe_user_id: stripe_session.customer,
        stripe_subscription_id: stripe_session.subscription,
        active: true
      )
      # TODO: Would be better to retrieve the plan name from Stripe
      flash.notice = "Subscription to Bronze Plan successful!"
    end

    @subscription = current_user.subscription
    if @subscription.stripe_subscription_id.present?
      ss = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
      stripe_product = Stripe::Product.retrieve(ss.items.data.first.plan.product)
      @product = {
        name: stripe_product.name,
        description: stripe_product.description
      }
      @subscription_info = {
        renews_on: Time.at(ss.current_period_end).strftime("%Y-%m-%d")
      }
    end
  end
end
