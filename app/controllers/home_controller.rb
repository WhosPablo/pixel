class HomeController < ApplicationController

  def index
    @new_question = Question.new
    #TODO change waiting on https://github.com/rails/rails/issues/24055
    @questions = Question.left_outer_joins(:question_recipients).distinct.where('question_recipients.user_id = ? OR questions.user_id = ?',
                                                                       current_user.id, current_user.id).first(15)
  end
end
