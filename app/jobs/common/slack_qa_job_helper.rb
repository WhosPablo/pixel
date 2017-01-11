class SlackQaJobHelper
  @@num_of_qs = 2

  def self.report_missing_quiki_profile(response_url)
    #TODO offer to make an account for them
    message = {
        text: "Looks like you haven't made an account on Quiki, make an account at http://www.askquiki.com",
        response_type: "ephemeral"
    }
    response = HTTParty.post(response_url, { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})
    Rails.logger.info response
  end

  def self.find_user_by_slack_id(client, slack_id)
    creator_slack_info = client.users_info(user: slack_id)

    # TODO maybe try to find by name?
    unless creator_slack_info.user.profile.email
      Rails.logger.warn("Unable to access the email corresponding to a slack_id #{creator_slack_info}")
    end
    user = User.find_by_email(creator_slack_info.user.profile.email)
    unless user
      Rails.logger.warn("Could not find user object for slack user")
      Rails.logger.warn creator_slack_info
    end
    user
  end

  def self.convert_question_to_attachment(question)
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

  def self.are_these_correct_quest(question, no_obj)
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
            "text": no_obj[:text],
            "type": "button",
            "value": no_obj[:value]
        }
    ]
    attach
  end

  def self.ask_question_as_quiki(question)
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

  def self.find_question_and_confirm(text, company, new_question)
    possible_qs = Question.find_relevant_question(text, company)
                      .records
                      .where("comments_count > 0")
                      .to_a[0]

    message = {}
    if possible_qs.count > 0
      message[:text] = "Here are some similar previous questions, do they answer your question?"
      message[:attachments] = []
      possible_qs.each do | question |
        question_attachment = SlackQaJobHelper.convert_question_to_attachment(question)
        message[:attachments].push(question_attachment)
      end
      no_obj = {
          text: "No",
          value: "no_public"
      }
      message[:attachments].push(SlackQaJobHelper.are_these_correct_quest(new_question, no_obj))
    else
      message[:text] = "This question hasn't been asked before. Can someone answer with /a to create a new answer?"
    end
    message
  end

  def self.find_question_or_offer_to_ask(text, company, new_question)
    possible_qs = Question.find_relevant_question(text, company)
                      .records
                      .where("comments_count > 0")
                      .to_a[0..@@num_of_qs]

    message = {}
    if possible_qs.count > 0
      message[:text] = "Here are some similar previous questions, do they answer your question?"
      message[:attachments] = []
      possible_qs.each do | question |
        question_attachment = SlackQaJobHelper.convert_question_to_attachment(question)
        message[:attachments].push(question_attachment)
      end
      no_obj = {
          text: "No, ask my question",
          value: "no"
      }
      message[:attachments].push(SlackQaJobHelper.are_these_correct_quest(new_question, no_obj))
    else
      message[:text] = "Unable to find any similar questions."
      message[:attachments] = []
      message[:attachments].push(SlackQaJobHelper.ask_question_as_quiki(new_question))
    end
    message
  end

  def self.create_question(user, text)
    Question.create(user: user, body: text)
  end

  def self.populate_question(user, team, channel, question, client)
    # Populate question
    SlackQuestionIndex.create(team_id: team, channel_id: channel, question: question)
    question.auto_populate_labels!
    question.recipients << SlackQaJobHelper.attempt_to_find_recipients(client, channel, user)

  end

  def self.attempt_to_find_recipients(client, channel_id, creator_id)
    recipients = []
    channel_slack_info = client.channels_info(channel: channel_id)
    if channel_slack_info
      channel_slack_info.channel.members.each do | member |
        if member != creator_id
          member_usr = SlackQaJobHelper.find_user_by_slack_id(client, member)
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

end
