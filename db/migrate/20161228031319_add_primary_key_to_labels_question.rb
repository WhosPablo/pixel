class AddPrimaryKeyToLabelsQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :labels_questions, :id, :primary_key

  end
end
