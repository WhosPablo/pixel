class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_permission
  before_action :check_admin, only: [:ban]
  before_action :check_ownership, only: [:edit, :notifications, :clear_notifications]
  before_action :find_notifications, only: [:show, :edit, :notifications]
  respond_to :html, :js

  def show
    if @user == current_user
      redirect_to questions_path
    else
      @questions = Question
                       .paginate(page: params[:page], per_page: 15)
                       .left_outer_joins(:question_recipients)
                       .where('(question_recipients.user_id = ? AND questions.user_id = ?)
OR (question_recipients.user_id = ? AND questions.user_id = ?)',
                              current_user.id, @user.id, @user.id, current_user.id)
    end

  end

  def edit
  end


  def mentionable
    render json: @user.company.users.as_json(only: [:id, :username]), root: false
  end

  def notifications
    @activities = @user.activities.paginate(page: params[:page], per_page: 20)
                      .order(created_at: :desc)
  end

  def clear_notifications
    @user.update(last_notification_ack: Time.now)
  end

  def ban
    @user.banned = true
    @user.save!
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User was successfully banned.' }
      format.json { head :no_content }
      format.js
    end
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

  def check_admin
    unless current_user.is_admin
      redirect_to root_path, :alert => 'Unauthorized because you are not an admin'
    end
  end

end
