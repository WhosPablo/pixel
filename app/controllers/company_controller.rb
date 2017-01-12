class CompanyController < ApplicationController
  before_action :authenticate_user!
  before_action :find_notifications

  before_action :set_company
  before_action :check_permission



  def edit
    @company_users = User.paginate(page: params[:page], per_page: 25)
                         .where(company: @company)
    @slack_teams = SlackTeam.where(company: @company)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  def check_permission
    unless current_user.company == @company and current_user.is_admin
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end

end
