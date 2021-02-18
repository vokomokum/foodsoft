class AddPaymentRemindersSentAtToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :payment_reminders_sent_at, :datetime
  end
end
