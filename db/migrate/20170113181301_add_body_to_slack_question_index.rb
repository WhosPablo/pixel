class AddBodyToSlackQuestionIndex < ActiveRecord::Migration[5.0]
  def change
    add_column :slack_question_indices, :body, :text, default: nil

  end
end
