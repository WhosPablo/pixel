module QuikiBot
  module Commands
    class AutoAnswer < SlackRubyBot::Commands::Base
      command "auto answer on", "auto answer off", "auto answers on", "auto answers off"

      def self.call(client, data, match)
        logger.info "Command: #{match}, user=#{data.user}, channel=#{data.channel}"
        channel = SlackChannel.find_or_create_by(channel_id: data.channel, team_id: data.team)
        if match.to_s.include? "off"
          channel.auto_answer = false
          channel.save!
          client.say(channel: data.channel, text: "Ok turning auto answers off. To turn them back on simply type @quiki auto answer on")
        elsif match.to_s.include? "on"
          channel.auto_answer = true
          channel.save!
          client.say(channel: data.channel,  text: "Ok turning auto answers on. To turn them off again simply type @quiki auto answer off")
        else
          client.say(channel: data.channel,  text: "Please say `on` or `off` in your message so I know whether to turn auto answers on or off")
        end
      end
    end
  end
end
