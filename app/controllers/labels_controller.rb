class LabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_label, only: [:show, :destroy]
  before_action :check_permission
  before_action :check_admin, only: [:destroy ]
  before_action :find_notifications
  respond_to :js

  def index
    @labels = Label
                  .paginate(page: params[:page], per_page: 25)
                  .where(companies_id: current_user.company)
                  .where("questions_count > ?", 0)
                  .order('questions_count DESC, name ASC')
  end

  def show
    @questions = @label.questions.paginate(page: params[:page], per_page: 15)
  end

  def destroy
    if @label.destroy
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Label was successfully deleted.' }
        format.json { head :no_content }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Unable to delete label because #{@label.errors}" }
        format.js { render :error, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_label
    @label = Label.find(params[:id])
  end


  def check_permission
    unless @label.company == current_user.company
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end

end
