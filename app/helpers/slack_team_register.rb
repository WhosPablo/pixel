require_relative '../slack/slack-ruby-bot-server'

class SlackTeamRegister

  def self.register_code(code, company)
    client = Slack::Web::Client.new

    raise 'Missing SLACK_CLIENT_ID or SLACK_CLIENT_SECRET.' unless ENV.key?('SLACK_CLIENT_ID') && ENV.key?('SLACK_CLIENT_SECRET')

    rc = client.oauth_access(
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        code: code
    )

    token = rc['bot']['bot_access_token']
    team = SlackTeam.where(token: token).first
    team ||= SlackTeam.where(team_id: rc['team_id']).first
    if team && !team.active?
      team.activate!(token)
    elsif team
      raise TeamAlreadyRegistered.new("Quiki has already been added to #{team.name} Team. Email help@askquiki.com if this is not the case")
    else
      team = SlackTeam.create!(
          token: token,
          team_id: rc['team_id'],
          name: rc['team_name'],
          company: company
      )
    end

    SlackRubyBotServer::Service.instance.create!(team)
  end

end

class TeamAlreadyRegistered < StandardError
  attr_reader :message

  def initialize(message)
    @message = message
  end
end
