class CreateSlackQuestionIndex< ActiveRecord::Migration[5.0]
  def change
    create_table :slack_question_indexes do |t|
      t.string :team_id
      t.string :channel_id
      t.timestamps
    end
    add_reference :slack_question_indexes, :question, index: true, foreign_key: true
  end
end
