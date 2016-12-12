class ActivityCreator
  include AbstractController::Rendering

  def self.notifications_for_comments(comment)
    if comment.commentable_type.eql? "Question"
      question = Question.find(comment.commentable_id)
      question.create_activity action: :commented, owner: comment.user

      question.recipients.each do | recipient |
        notify_recipients_of_new_cmnt(question, comment, recipient)
      end
      notify_q_owner_of_new_cmnt(question, comment)
    end
  end

  def self.notifications_for_questions(question, recipients)
    recipients.each do | recipient |
      notify_recipients_of_new_q(question, recipient)
    end
  end

  private

  def self.notify_recipients_of_new_q(question, recipient)
    activity = recipient.create_activity action: :question_asked, owner: question.user, recipient: question
    NotificationsChannel.broadcast_to(
        recipient,
        title: "Notification",
        body: ActionController::Base.new.render_to_string(
            template: 'shared/_notification_helper.html.erb',
            locals: { activity: activity }
        )
    )
  end

  def self.notify_recipients_of_new_cmnt(question, comment, recipient)
    unless recipient == comment.user
      activity = recipient.create_activity action: :question_commented, owner: comment.user, recipient: question
      NotificationsChannel.broadcast_to(
          recipient,
          title: "Notification",
          body: ActionController::Base.new.render_to_string(
              template: 'shared/_notification_helper.html.erb',
              locals: { activity: activity }
          )
      )
    end
  end

  def self.notify_q_owner_of_new_cmnt(question, comment)
    unless question.user ==  comment.user
      activity = question.user.create_activity action: :question_answered, owner: comment.user, recipient: question
      NotificationsChannel.broadcast_to(
          question.user,
          title: "Notification",
          body: ActionController::Base.new.render_to_string(
              template: 'shared/_notification_helper.html.erb',
              locals: { activity: activity }
          )
      )
    end
  end
end
