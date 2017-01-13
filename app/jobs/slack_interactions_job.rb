require 'common/slack_qa_job_helper'

class SlackInteractionsJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    #TODO better error reporting here
    logger.error "ERROR processing Slack interaction "
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
    throw exception
  end


  def perform(params)
    process_command(params)
  end

  def process_command(params)
    team = SlackTeam.find_by_team_id(params[:team][:id])
    client = Slack::Web::Client.new
    client.token = team.token

    creator = SlackQaJobHelper.find_user_by_slack_id(client, params[:user][:id])

    unless creator
      SlackQaJobHelper.report_missing_quiki_profile(params[:response_url])
      raise "Could not find the user object for the creator of an interaction from Slack, User ID: #{params[:user][:id]}"
    end

    if params[:actions].length > 1
      raise "Unexpected multiple actions team #{params[:team][:id]}. Actions #{params[:actions]}"
    elsif !params[:actions].first[:name].eql? "question_answered"
      raise "Unexpected action team #{params[:team][:id]}. Action #{params[:actions].first}"
    else
      case params[:actions].first[:value]
        when "yes"
          del_question_created(params[:callback_id])
        when "no"
          ask_question_for_user(creator, params)
        else
          logger.error("Unexpected action value #{params}")
          raise "Unexpected action value #{params}"
      end
    end
  end

  def del_question_created(callback_id)
    # check that the callback id contains a question
    if callback_id[/(\d+)/].to_i
      question_id = callback_id[/(\d+)/].to_i
      Question.find(question_id).destroy
    else
      raise "Could not properly decode question id #{params}"
    end
  end

  def ask_question_for_user(creator, params)

    question_id = params[:callback_id][/(\d+)/].to_i
    unless question_id
      raise "Could not properly decode question id #{params}"
    end
    question = Question.find(question_id)

    message = {
        text: "Question from <@#{params[:user][:id]}>. Please begin your answer with /a ",
        attachments: [ {
                           text: question.body
                       } ],
        response_type: "in_channel",
        replace_original: false
    }
    logger.info HTTParty.post(params[:response_url], { body: message.to_json, headers: {
      "Content-Type" => "application/json"
    }})
  end
end
