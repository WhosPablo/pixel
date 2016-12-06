class PopulateCompaniesInQuestions < ActiveRecord::Migration[5.0]
  def change
    Question.reset_column_information
    for question1 in Question.all
      question1.company =  question1.user.company
      question1.save!
    end
  end
end
