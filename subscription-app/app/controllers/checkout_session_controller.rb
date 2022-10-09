# Better name: StripeSessionController?
class CheckoutSessionController < ApplicationController
  # FIXME: Shouldn't need this, add CSRF token to _checkout.html.erb
  skip_before_action :verify_authenticity_token

  # TODO: success_url should be something like /users/charge which later redirects to info
  # so some of the logic in users_controller#info can be split out to charge method
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

  # what if there is no current_user?
  # does Stripe provide any params on return_url so we can know if user cancelled their subscription?
  # maybe the only way to know is to implement webhooks
  def create_portal_session
    begin
      session = Stripe::BillingPortal::Session.create({
        customer: current_user.subscription.stripe_user_id,
        return_url: "#{request.base_url}/users/info"
      })
      redirect_to session.url, status: 303
    rescue StandardError => e
      payload = { 'error': { message: e.error.message } }
      render :json => payload, :status => :bad_request
    end
  end
end