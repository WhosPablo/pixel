class AddCompanyToQuestions < ActiveRecord::Migration[5.0]
  def change
    add_reference :questions, :companies, index: true, foreign_key: true
  end
end
