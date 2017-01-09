module SlackRubyBotServer
  class Server < SlackRubyBot::Server
    attr_accessor :team

    def initialize(attrs = {})
      attrs = attrs.dup
      @team = attrs.delete(:team)
      raise 'Missing team' unless @team
      attrs[:token] = @team.token
      super(attrs)
      client.owner = @team
    end

    def restart!(wait = 1)
      # when an integration is disabled, a live socket is closed, which causes the default behavior of the client to restart
      # it would keep retrying without checking for account_inactive or such, we want to restart via service which will disable an inactive team
      logger.info "#{team.name}: socket closed, restarting ..."
      SlackRubyBotServer::Service.instance.restart! team, self, wait
      client.owner = team
    end

    on :channel_joined do |client, data|
      logger.info "#{client.owner.name}: joined ##{data.channel['name']}."
      message = <<-EOS.freeze

Hey! I'm Quiki, here to help save and organize your knowledge.

Anytime you want to ask a question type `/q` and I'll
try to figure out if it has been asked before. If it hasn't been asked before, i'll save it so that it doesn't have to be asked again!

Type `/a` so that I can add your answer to the question asked through Quiki.

If you ever forget this just type `@quiki help` to a helpful overview of what I can do.

      EOS
      client.say(channel: data.channel['id'], text: message)
    end

  end
end
