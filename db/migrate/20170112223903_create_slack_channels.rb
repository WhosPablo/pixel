class CreateSlackChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :slack_channels do |t|
      t.string :team_id
      t.string :channel_id
      t.boolean :auto_answer, default: true
      t.timestamps
    end
    add_reference :slack_channels, :companies, index: true, foreign_key: true
    add_reference :slack_channels, :slack_teams, index: true, foreign_key: true
  end
end
