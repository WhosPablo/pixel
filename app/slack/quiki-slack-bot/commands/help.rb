module QuikiBot
  module Commands
    class Help < SlackRubyBot::Commands::Base

      def self.call(client, data, _match)
        logger.info "HELP: #{client.owner}, user=#{data.user}"
        client.say(channel: data.channel, text: QuikiBot::INFO)
      end
    end
  end
end
