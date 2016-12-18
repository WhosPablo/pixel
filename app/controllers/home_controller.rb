class HomeController < ApplicationController
  before_action :authenticate_user!, except: :front_page

  def index
    #TODO move this out of here
    if params.has_key?(:code)
      SlackTeamRegister.register_code(params[:code])
    end

    @new_question = Question.new
    # @questions = Question.where(companies_id: current_user.company).first(10)
    #                  .map { | question | QuestionHelper.set_headlessness(question, current_user) }
    @labels = Label.where(companies_id: current_user.company)
  end


  private

  def set_headlessness
    unless self.is_recipient current_user or self.belongs_to current_user
      @question.headless = true
      @question.user = nil # To avoid a programming error causing a leak of information
    end
  end
end
