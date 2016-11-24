class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_ownership, only: [:edit]

  respond_to :html, :js

  def show
    @questions = Question.left_outer_joins(:question_recipients).where('(question_recipients.user_id = ? AND questions.user_id = ?)
 OR (question_recipients.user_id = ? AND questions.user_id = ?)', current_user.id, @user.id, @user.id, current_user.id)
  end

  def edit
  end


  def mentionable
    render json: @user.company.users.as_json(only: [:id, :username]), root: false
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
