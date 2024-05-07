class AddUnreadThreadMessageToTUserChannels < ActiveRecord::Migration[5.2]
  def change
     add_column :t_user_channels, :unread_thread_message, :string, after: :unread_channel_message
  end
end
