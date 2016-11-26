class FixNotificationColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :last_notfication_ack, :last_notification_ack
  end
end
