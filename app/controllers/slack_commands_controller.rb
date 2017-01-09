class SlackCommandsController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def create
    return render json: {}, status: 403 unless valid_slack_token?
    SlackQAIndexerJob.perform_later command_params.to_h

    case params[:command]
      when "/q"
        render json: {text: "Searching previous questions...", response_type: "ephemeral" }, status: :created
      when "/a"
        render json: { response_type: "in_channel" }, status: :created
      else
        logger.error("Could not find how to process #{params}")
        raise "Unexpected command #{params}"
    end


  end

  private

  def valid_slack_token?
    ENV['SLACK_VERIFICATION_TOKEN'] == params[:token]
  end

  # Only allow a trusted parameter "white list" through.
  def command_params
    params.permit(:text, :token, :user_id, :response_url, :command, :channel_id, :team_id, :domain,
                  :team_domain, :channel_name, :user_name)
  end


end
