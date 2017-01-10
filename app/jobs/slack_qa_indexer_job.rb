class SlackQAIndexerJob < ApplicationJob
  queue_as :default
  @@num_of_qs = 2

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
      report_missing_quiki_profile(params[:response_url])
      raise "Could not find the user object for the creator of a question/answer from Slack, User ID: #{params[:user][:id]}"
    end
    case params[:command]
      when "/q"
        search_question_from_slack(creator, params, team, client)
      when "/a"
        create_answer_from_slack(creator, params)
      else
        logger.error("Could not find how to process #{params}")
        raise "Unexpected command #{params}"
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

    response = HTTParty.post(params[:response_url], { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})
    logger.info response
  end

  def search_question_from_slack(creator, params, team, client)
    new_question = Question.create(user: creator, body: params[:text])

    possible_qs = Question.find_relevant_question(params[:text], team.company)
                      .records
                      .first(@@num_of_qs)

    message = {}
    if possible_qs.count > 0
      message[:text] = "Here are some similar previous questions, do they answer your question?"
      message[:attachments] = []

      possible_qs.each do | question |
        question_attachment = convert_question_to_attachment(question)
        message[:attachments].push(question_attachment)
      end

      message[:attachments].push(are_these_correct_quest(new_question))
    else
      message[:text] = "Unable to find any similar questions."
      message[:attachments] = []
      message[:attachments].push(ask_question_as_quiki(new_question))
    end

    logger.info HTTParty.post(params[:response_url], { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})

    # Populate question
    SlackQuestionIndex.create(team_id: params[:team_id], channel_id: params[:channel_id], question: new_question)
    new_question.auto_populate_labels!
    new_question.recipients << attempt_to_find_recipients(client, params[:channel_id], params[:user_id])
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


  def convert_question_to_attachment(question)
    converted_q = {}
    converted_q[:fallback] = "Similar question on quiki at #{Rails.application.routes.url_helpers.question_url(question, :host => 'www.askquiki.com')}"
    converted_q[:color] = "#40b9c9"
    converted_q[:title] = question.body
    converted_q[:title_link] = Rails.application.routes.url_helpers.question_url(question, :host => 'www.askquiki.com')
    converted_q[:fields] = []

    if question.comments.last
      converted_q[:footer] = question.comments.last.user.full_name
      converted_q[:ts] = question.comments.last.updated_at.to_i
      question.comments.last(2).each do | comment |
        field = {}
        field[:value] = comment.comment
        field[:short] = false
        converted_q[:fields].push(field)
      end
    else
      field = {}
      field[:value] = "No answers for this question yet :("
      field[:short] = false
      converted_q[:fields].push(field)
    end
    converted_q
  end

  def are_these_correct_quest(question)
    attach = {}
    attach[:text] = "Did these answer your question?"
    attach[:fallback] = "You are unable to determine if the previous similar questions answered your question?"
    attach[:attachment_type] = "default"
    attach[:callback_id]= "Q#{question.id}"
    attach[:actions] = [
        {
            "name": "question_answered",
            "text": "Yes",
            "type": "button",
            "value": "yes"
        },
        {
            "name": "question_answered",
            "text": "No, ask my question",
            "type": "button",
            "value": "no"
        }
    ]
    attach
  end

  def ask_question_as_quiki(question)
    attach = {}
    attach[:text] = "Would you like me to ask your question on the channel?"
    attach[:fallback] = "You are unable to tell Quiki to ask your question"
    attach[:attachment_type] = "default"
    attach[:callback_id]= "Q#{question.id}"
    attach[:actions] = [
        {
            "name": "question_answered",
            "text": "Yes",
            "type": "button",
            "value": "no"
        },
        {
            "name": "question_answered",
            "text": "No",
            "type": "button",
            "value": "yes"
        }
    ]
    attach
  end

end
