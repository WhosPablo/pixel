class CommentActivityJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    #TODO better error reporting here
    logger.error "ERROR unable to notify all users for a question "
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
    throw exception
  end

  def perform(comment)
    ActivityCreator.notifications_for_comments(comment)
  end
end
