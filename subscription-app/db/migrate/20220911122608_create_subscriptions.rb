class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_user_id
      t.boolean :active, null: false, default: false
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
