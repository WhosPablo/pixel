module QuikiBot
  module Commands
    class Question < SlackRubyBot::Commands::Base
      match(/[\s\S]*[\?]/)

      def self.call(client, data, _match)
        logger.info "Question: #{client.owner}, user=#{data.user}, match=#{_match}"

        # Create a parser object
        tgr = EngTagger.new

        words = tgr.get_words(_match.to_s)

        if words.keys.count > 0 and !data.user.blank?

          text = _match.to_s
          team = SlackTeam.find_by_team_id(data.team)

          full_client =  Slack::Web::Client.new
          full_client.token = team.token

          creator = SlackQaJobHelper.find_user_by_slack_id(full_client, data.user)

          new_question = SlackQaJobHelper.create_question(creator, text)

          message = SlackQaJobHelper.find_question_and_confirm(text, team.company, new_question)

          full_client.chat_postMessage(channel: data.channel, text: message[:text], attachments: message[:attachments])

          SlackQaJobHelper.populate_question(data.user, data.team, data.channel, new_question, full_client)

        end
      end
    end
  end
end