class UserMailer < ApplicationMailer
  default from: "Quiki <questions@q.askquiki.com>"


  def question_recipient_email(user, question)
    @user = user
    @question = question

    if @question.user.full_name
      @from_name = @question.user.full_name
    else
      @from_name =  @question.user.username
    end
    mail(to: @user.email, subject:  @from_name.titleize + ' has asked you a question')
  end
end
