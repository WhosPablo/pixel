class SlackQAIndexerJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    #TODO better error reporting here
    logger.error "ERROR indexing question/answer from slack "
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
    throw exception
  end

  def perform(params)
    process_command(params)
  end

  def process_command(params)
    team = SlackTeam.find_by_team_id(params[:team_id])
    client = Slack::Web::Client.new
    client.token = team.token

    creator = find_user_by_slack_id(client, params[:user_id])
    unless creator
      message = {
          text: "Looks like you haven't made an account on Quiki, make an account at http://www.askquiki..com",
          response_type: "ephemeral"
      }
      HTTParty.post(params[:response_url], { body: message.to_json, headers: {
          "Content-Type" => "application/json"
      }})
      raise "Could not find the user object for the creator of a question/answer from Slack"
    end
    case params[:command]
      when "/q"
        create_question_from_slack(creator, params, client)
      when "/a"
        create_answer_from_slack(creator, params)
      else
        logger.error("Could not find how to process #{params}")
    end

  end

  def create_answer_from_slack(creator, params)

    # Attempt to find  the relevant question
    question = SlackQuestionIndex.where(team_id: params[:team_id], channel_id: params[:channel_id]).last.question

    question.comments.create(comment: params[:text], user: creator)

    message = {
        text: "Thanks, your answer has been posted on Quiki",
        response_type: "ephemeral"
    }

    HTTParty.post(params[:response_url], { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})
  end

  def create_question_from_slack(creator, params, client)
    question = Question.create(user: creator, body: params[:text])
    SlackQuestionIndex.create(team_id: params[:team_id], channel_id: params[:channel_id], question: question)

    message = {
        text: "Please begin your answer with /a or answer at #{Rails.application.routes.url_helpers.question_url(question,
                                                                                                                 :host => 'www.askquiki.com')}",
        response_type: "in_channel"
    }

    HTTParty.post(params[:response_url], { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})


    question.auto_populate_labels!
    question.recipients << attempt_to_find_recipients(client, params[:channel_id], params[:user_id])
   end

  def attempt_to_find_recipients(client, channel_id, creator_id)
    recipients = []
    channel_slack_info = client.channels_info(channel: channel_id)
    if channel_slack_info
      channel_slack_info.channel.members.each do | member |
        if member != creator_id
          member_usr = find_user_by_slack_id(client, member)
          if member_usr
            recipients << member_usr
          end
        end
      end
    else
      logger.warn("Unable to get information about the channel, could be a private channel")
      logger.warn(params)
    end
    recipients
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
