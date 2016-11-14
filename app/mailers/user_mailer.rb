class UserMailer < ApplicationMailer


  def question_recipient_email(user, question)
    @user = user
    @question = question

    if @question.user.full_name
      @from_name = @question.user.full_name
    else
      @from_name =  @question.user.username
    end
    mail(to: @user.email, subject:  @from_name + ' has asked you a question')
  end
end
