module QuikiBot
  module Commands
    class Unknown < SlackRubyBot::Commands::Base
      match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)

      def self.call(client, data, _match)
        logger.info "Command: #{_match}, user=#{data.user}"
        client.say(channel: data.channel, text: "Hi <@#{data.user}>!")
        client.say(channel: data.channel, text: QuikiBot::INFO)
      end
    end

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
