class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_permission
  before_action :check_ownership, only: [:edit, :notifications, :clear_notifications]

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

  def notifications
    @activities = Public@user.activities.all.order(created_at: :desc)
  end

  def clear_notifications
    @user.update(last_notification_ack: Time.now)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def check_ownership
    unless current_user == @user
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end

  def check_permission
    unless current_user.company == @user.company
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end

end
