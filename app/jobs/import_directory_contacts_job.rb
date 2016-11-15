class ImportDirectoryContactsJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    #TODO better error reporting here
    logger.fatal "ERROR ImportDirectoryContactsJob UNABLE TO IMPORT CONTACTS "
    logger.fatal exception
    throw exception
  end

  def perform(auth_token, user)
    GhostUserCreator.start_with_google_token(auth_token, user)
  end
end
