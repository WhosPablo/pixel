class ImportDirectoryContactsJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    #TODO better error reporting here
    logger.error "ERROR ImportDirectoryContactsJob UNABLE TO IMPORT CONTACTS "
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
    throw exception
  end

  def perform(auth_token, user)
    GhostUserCreator.start_with_google_token(auth_token, user)
  end
end
