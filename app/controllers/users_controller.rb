class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  respond_to :html, :js
  def show
  end

  def mentionable
    render json: @user.company.users.as_json(only: [:id, :username]), root: false
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
