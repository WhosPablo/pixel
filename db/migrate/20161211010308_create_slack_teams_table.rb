class CreateSlackTeamsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :slack_teams do |t|
      t.string :team_id
      t.string :name
      t.string :domain
      t.string :token
      t.boolean :active, default: true
      t.timestamps
    end
    add_reference :slack_teams, :companies, index: true, foreign_key: true

  end
end
