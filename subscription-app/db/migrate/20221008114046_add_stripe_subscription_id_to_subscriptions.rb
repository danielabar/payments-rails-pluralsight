class AddStripeSubscriptionIdToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :stripe_subscription_id, :string
  end
end
