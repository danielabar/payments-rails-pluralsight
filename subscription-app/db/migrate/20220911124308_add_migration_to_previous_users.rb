class AddMigrationToPreviousUsers < ActiveRecord::Migration[6.1]
  def up
    User.all.each do |user|
      user.create_subscription
    end
  end
end
