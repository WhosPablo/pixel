class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_ownership, only: [:edit, :update]

  respond_to :html, :js
  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def mentionable
    render json: @user.company.users.as_json(only: [:id, :username]), root: false
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
