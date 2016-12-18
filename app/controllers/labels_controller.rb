class LabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_label, only: [:show]
  before_action :check_permission, only: [:show]

  def index
    @labels = current_user.company.labels
  end

  def show
    @questions = @label.questions
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
