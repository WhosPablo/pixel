class CreateQuestionRecipients < ActiveRecord::Migration[5.0]
  def change
    create_table :question_recipients do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :question, foreign_key: true

      t.timestamps
    end
  end
end
