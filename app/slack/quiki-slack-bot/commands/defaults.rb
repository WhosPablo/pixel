module QuikiBot
  module Commands
    # class Unknown < SlackRubyBot::Commands::Base
    #   match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)
    #
    #   def self.call(client, data, _match)
    #
    #   end
    # end

    class About < SlackRubyBot::Commands::Base
      command 'about', 'hi' do |client, data, match|
        logger.info "HELP: #{client.owner}, user=#{data.user}"
        client.say(channel: data.channel, text: QuikiBot::INFO)
      end
    end
  end
end
