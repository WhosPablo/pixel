class CreateLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :labels do |t|
      t.string :name

      t.timestamps
    end
    add_reference :labels, :companies, index: true, foreign_key: true

    create_join_table :labels, :questions do |t|
      t.index [:label_id, :question_id]
      t.index [:question_id, :label_id]
    end
  end
end
