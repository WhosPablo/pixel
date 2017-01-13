class AddUserToSlackQuestionIndices < ActiveRecord::Migration[5.0]
  def change
    add_reference :slack_question_indices, :users, index: true, foreign_key: true

  end
end
