class AddCompanyTable < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :domain
      t.timestamps
    end
    add_index :companies, :domain, unique: true
    add_reference :users, :companies, index: true, foreign_key: true
  end
end
