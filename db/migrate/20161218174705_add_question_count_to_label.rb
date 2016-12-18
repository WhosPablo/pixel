class AddQuestionCountToLabel < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :questions_count, :integer, default: 0
  end
end
