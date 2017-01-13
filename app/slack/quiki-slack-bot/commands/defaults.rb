module QuikiBot
  module Commands

    class About < SlackRubyBot::Commands::Base
      match(/^(?<bot>[[:alnum:][:punct:]@<>]*)$/u)

      command 'about', 'hi' do |client, data, match|
        logger.info "Command: #{match}, user=#{data.user}"
        client.say(channel: data.channel, text: "Hi <@#{data.user}>!")
        client.say(channel: data.channel, text: QuikiBot::INFO)
      end
    end
  end
end
