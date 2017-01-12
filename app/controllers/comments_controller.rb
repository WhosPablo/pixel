class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:destroy]
  before_action :require_ownership, only: [:destroy]
  before_action :find_commentable, only: :create
  respond_to :js

  def create
    @comment = @commentable.comments.new do |comment|
      comment.comment = params[:comment_text]
      comment.user = current_user
    end

    respond_to do |format|
      if @comment.save
        format.js
      else
        @messages = @comment.errors.full_messages
        format.js { render :error, status: :unprocessable_entity }
      end
    end
    
  end

  def destroy
    @comment.destroy
  end

  private

  def find_commentable
    @commentable_type = params[:commentable_type].classify
    @commentable = @commentable_type.constantize.find(params[:commentable_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def require_ownership
    unless @comment.belongs_to current_user or current_user.is_admin
      redirect_to root_path, :alert => 'Unauthorized'
    end
  end

end
