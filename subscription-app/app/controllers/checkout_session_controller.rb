# Better name: StripeSessionController?
class CheckoutSessionController < ApplicationController
  def create
    begin
      prices = Stripe::Price.list(expand: ['data.product'])
      session = Stripe::Checkout::Session.create({
        mode: 'subscription',
        line_items: [{
          quantity: 1,
          price: prices.data[0].id
        }],
        success_url: "#{request.base_url}/users/charge?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{request.base_url}/users/info",
      })
      redirect_to session.url, status: 303
    rescue StandardError => e
      payload = { 'error': { message: e.error.message } }
      render :json => payload, :status => :bad_request
    end
  end

  def create_portal_session
    begin
      session = Stripe::BillingPortal::Session.create({
        customer: current_user.subscription.stripe_user_id,
        return_url: "#{request.base_url}/users/manage"
      })
      redirect_to session.url, status: 303
    rescue StandardError => e
      payload = { 'error': { message: e.error.message } }
      render :json => payload, :status => :bad_request
    end
  end
end