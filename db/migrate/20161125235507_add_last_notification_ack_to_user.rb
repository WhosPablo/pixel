class AddLastNotificationAckToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_notfication_ack, :datetime
  end
end
