class ApplicationJob < ActiveJob::Base


  def report_missing_quiki_profile(response_url)
    #TODO offer to make an account for them
    message = {
        text: "Looks like you haven't made an account on Quiki, make an account at http://www.askquiki.com",
        response_type: "ephemeral"
    }
    response = HTTParty.post(response_url, { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})
    logger.info response
  end


  def find_user_by_slack_id(client, slack_id)
    creator_slack_info = client.users_info(user: slack_id)

    # TODO maybe try to find by name?
    unless creator_slack_info.user.profile.email
      logger.warn("Unable to access the email corresponding to a slack_id #{creator_slack_info}")
    end
    user = User.find_by_email(creator_slack_info.user.profile.email)
    unless user
      logger.warn("Could not find user object for slack user")
      logger.warn creator_slack_info
    end
    user
  end
end
