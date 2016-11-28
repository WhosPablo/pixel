class SearchController < ApplicationController
  def search
    if params[:q].nil?
      @questions = []
    else
      @questions = Question.search(params[:q]).records.to_a
    end
  end
end
