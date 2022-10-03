class ApplicationController < ActionController::Base
  # Stripe needs client to invoke POST /create-payment-intent from js
  # https://stackoverflow.com/questions/39350937/disable-actioncontrollerinvalidauthenticitytoken-only-for-json-request
  protect_from_forgery unless: -> { request.format.json? }
end
