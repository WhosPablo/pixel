class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :require_ownership, only: [:edit, :update, :destroy]
  before_action :check_permission, only: [:show]
  before_action :set_headlessness, only: [:show]
  before_action :find_notifications, only: [:show, :edit, :index ]

  # GET /questions
  # GET /questions.json
  def index
    #TODO change waiting on https://github.com/rails/rails/issues/24055
    @questions = Question.left_outer_joins(:question_recipients)
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
        send_initial_email_to_all_recipients
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.js
      else
        @messages = @question.errors.full_messages
        format.html { render :new, notice: @question.errors.message }
        format.js { render :error, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        send_initial_email_to_recipients_csv(question_params[:recipients_list_csv])
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
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

    def set_headlessness
      unless @question.is_recipient current_user or @question.belongs_to current_user
        @question.headless = true
        @question.user = nil # To avoid a programming error causing a leak of information
      end
    end

    def require_ownership
      unless @question.belongs_to current_user
        redirect_to question_path, :alert => 'Unauthorized'
      end
    end

  def check_permission
    unless @question.company == current_user.company
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end

  def send_initial_email_to_recipients_csv(recipients_csv)
    recipients_users = @question.recipients_csv_to_user_obj(recipients_csv, current_user)
    recipients_users.each do | recipient |
      UserMailer.question_recipient_email(recipient, @question).deliver_now
    end
  end

  def send_initial_email_to_all_recipients
    @question.recipients.each do | recipient |
      UserMailer.question_recipient_email(recipient, @question).deliver_now
    end
  end

end
