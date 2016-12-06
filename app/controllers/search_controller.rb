class SearchController < ApplicationController
  def search
    if params[:q].nil?
      @questions = []
    else
      @questions = Question.search(params[:q], current_user)
                       .records
                       .to_a
                       .map { | question | QuestionHelper.set_headlessness(question, current_user) }

    end
  end
end
