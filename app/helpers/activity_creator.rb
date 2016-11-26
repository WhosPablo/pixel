class ActivityCreator


  def self.notifications_for_comments(comment)
    if comment.commentable_type.eql? "Question"
      question = Question.find(comment.commentable_id)
      question.recipients.each do | recipient |
        unless recipient == comment.user
          recipient.create_activity action: :question_commented, owner: comment.user, recipient: question
        end
      end
      unless question.user ==  comment.user
        question.user.create_activity action: :question_answered, owner: comment.user, recipient: question
      end
      question.create_activity action: :commented, owner: comment.user
    end
  end

  def self.notifications_for_questions(question)
    question.recipients.each do | recipient |
      recipient.create_activity action: :question_asked, owner: question.user, recipient: question
    end

  end

end
