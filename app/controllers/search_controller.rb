class SearchController < ApplicationController
  before_action :authenticate_user!
  before_action :find_notifications

  def search
    if params[:q].nil?
      @questions = []
    else
      @questions = Question.search(params[:q], current_user)
                       .records
                       .to_a

    end
  end
end
