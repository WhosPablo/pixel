class QuestionActivityJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    #TODO better error reporting here
    logger.error "ERROR unable to notify all users for a QUESTION "
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
    throw exception
  end

  def perform(question)
    # Hard coded a second to allow some time for database to insert documents,
    # It's definitely a race condition
    new_recipients = question.recipients.where('question_recipients.created_at > ?',(question.updated_at - 1.seconds) )
    ActivityCreator.notifications_for_questions(question, new_recipients)
  end
end