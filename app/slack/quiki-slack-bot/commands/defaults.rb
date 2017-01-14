module QuikiBot
  module Commands

    class Default < SlackRubyBot::Commands::Base
      match(/^(?<bot>\w*)$/)

      def self.call(client, data, _match)
        QuikiBot::Commands::AnswerPrevious.call(client, data, _match)
      end
    end

    class About < SlackRubyBot::Commands::Base

      command 'about', 'hi' do |client, data, match|
        logger.info "Command: #{match}, user=#{data.user}"
        client.say(channel: data.channel, text: "Hi <@#{data.user}>!")
        client.say(channel: data.channel, text: QuikiBot::INFO)
      end
    end
  end
end
