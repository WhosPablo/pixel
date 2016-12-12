class RenameSlackQuestionIndexTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :slack_question_indexes, :slack_question_indices
  end
end
