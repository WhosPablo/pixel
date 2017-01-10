require 'common/slack_qa_job_helper'

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

    creator = SlackQaJobHelper.find_user_by_slack_id(client, params[:user_id])
    unless creator
      SlackQaJobHelper.report_missing_quiki_profile(params[:response_url])
      raise "Could not find the user object for the creator of a question/answer from Slack, User ID: #{params[:user_id]}"
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

    message = SlackQaJobHelper.find_question_or_offer_to_ask(params[:text], team.company, new_question)

    logger.info HTTParty.post(params[:response_url], { body: message.to_json, headers: {
        "Content-Type" => "application/json"
    }})

    # Populate question
    SlackQuestionIndex.create(team_id: params[:team_id], channel_id: params[:channel_id], question: new_question)
    new_question.auto_populate_labels!
    new_question.recipients << SlackQaJobHelper.attempt_to_find_recipients(client, params[:channel_id], params[:user_id])
   end


end
