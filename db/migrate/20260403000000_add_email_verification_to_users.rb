class AddEmailVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_verified_at, :datetime, precision: nil
    add_column :users, :email_verification_sent_at, :datetime, precision: nil
  end
end
