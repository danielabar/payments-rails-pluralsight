# Adapted from Sinatra example to Rails: https://stripe.com/docs/payments/quickstart
class PaymentIntentController < ApplicationController
  def create
    payment_intent = Stripe::PaymentIntent.create(
      amount: 999,
      currency: 'cad',
      automatic_payment_methods: {
        enabled: true,
      },
    )
    response = {
      clientSecret: payment_intent['client_secret']
    }
    respond_to do |format|
      format.json { render json: response }
    end
  end
end