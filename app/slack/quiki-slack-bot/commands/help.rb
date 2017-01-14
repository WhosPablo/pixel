module QuikiBot
  module Commands
    class Help < SlackRubyBot::Commands::Base

      def self.call(client, data, _match)
        logger.info "HELP: #{_match}, user=#{data.user}, channel=#{data.channel}, team=#{data.team}"
        client.say(channel: data.channel, text: QuikiBot::INFO)
      end
    end
  end
end
