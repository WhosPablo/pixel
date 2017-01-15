class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :require_ownership, only: [:edit, :update, :destroy]
  before_action :check_permission, only: [:show]
  before_action :find_notifications, only: [:show, :update, :edit, :index]

  # GET /questions
  # GET /questions.json
  def index
    #TODO change waiting on https://github.com/rails/rails/issues/24055
    @questions = Question.paginate(page: params[:page], per_page: 15)
                     .left_outer_joins(:question_recipients)
                     .where('question_recipients.user_id = ? OR questions.user_id = ?',
                                                            current_user.id, current_user.id)
                     .distinct
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @comments = @question.comments.all
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)
    @question.user = current_user
    respond_to do |format|
      if @question.save
        ActivityCreator.hard_notifications_for_questions(@question)
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.js
      else
        @messages = @question.errors.full_messages
        format.html { render :new, alert: @question.errors.message }
        format.js { render :error, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        # ActivityCreator.hard_notifications_for_questions(@question, question_params[:recipients_list_csv])
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        @messages = @question.errors.full_messages
        format.html { render :edit, alert: @question.errors.message }
        format.js { render :error, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy!
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Question was successfully deleted.' }
      format.json { head :no_content }
      format.js
    end
  end

  def auto_labels
    if params.has_key?(:question_text)
      render :json => LabelCreator.generate_labels(params[:question_text])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :body, :recipients_list_csv, :labels_csv)
    end

    def require_ownership
      unless @question.belongs_to current_user or current_user.is_admin
        redirect_to question_path, :alert => 'Unauthorized'
      end
    end

  def check_permission
    unless @question.company == current_user.company
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end


end
