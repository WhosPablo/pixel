class SlackInteractionsController < ApplicationController
  skip_before_action  :verify_authenticity_token


  def create
    slack_params = slack_interaction_params(allowed_params[:payload])
    return render json: {}, status: 403 unless valid_slack_token?(slack_params)
    if slack_params[:actions].length > 1
      logger.error "Unexpected multiple actions team #{slack_params[:team][:id]}. Actions #{slack_params[:actions]}"
    elsif !slack_params[:actions].first[:name].eql? "question_answered"
      logger.error "Unexpected action team #{slack_params[:team][:id]}. Action #{slack_params[:actions].first}"
    else
      case slack_params[:actions].first[:value]
        when "yes"
          SlackInteractionsJob.perform_later slack_params
          if slack_params.has_key?(:original_message)
            modified_original_message = slack_params[:original_message]
            modified_original_message[:attachments].pop
            modified_original_message[:attachments].push({ text: "Glad I could help!" })
            render json: modified_original_message, status: 200

          else
            render json: { text: "Glad I could help!", replace_original: false }, status: 200
          end
        when "no"
          SlackInteractionsJob.perform_later slack_params
          render json: { text: "Alright, I'll ask for you now..."}, status: 200
        when "no_public"
          render json: { text: "New question. Can someone answer with /a to create a new answer?"}, status: 200
        else
          logger.error("Unexpected action value #{slack_params}")
      end
    end
  end

  private

  def valid_slack_token?(slack_params)
    ENV['SLACK_VERIFICATION_TOKEN'] == slack_params[:token]
  end

  # Only allow a trusted parameter "white list" through.
  def allowed_params
    params.permit(:payload)
  end
  def slack_interaction_params(params_string)
    JSON.parse(params_string).with_indifferent_access
  end

end
