class Unknown < SlackRubyBot::Commands::Base
  match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)

  def self.call(client, data, _match)
    logger.info "Command: #{_match}, user=#{data.user}"
    # client.say(channel: data.channel, text: "unknown")
    client.say(channel: data.channel, text: QuikiBot::INFO)
  end
end