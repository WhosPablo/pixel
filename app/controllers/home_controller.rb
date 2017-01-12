class HomeController < ApplicationController
  before_action :authenticate_user!, except: :front_page
  before_action :find_notifications

  def index
    #TODO move this out of here
    if params.has_key?(:code)
      begin
        SlackTeamRegister.register_code(params[:code], current_user.company)
      rescue TeamAlreadyRegistered => e
        flash[:alert] = e.message
      end
      flash[:notice] = "Successfully registered Quiki on Slack. Add @quiki to your preferred channel!"
    end

    @new_question = Question.new
    @labels = Label
                  .paginate(page: params[:page], per_page: 25)
                  .where(companies_id: current_user.company)
                  .where("questions_count > ?", 0)
                  .order('questions_count DESC, name ASC')

  render 'home/index', :locals => {:tour =>  params.has_key?(:tour)}
  end

end
