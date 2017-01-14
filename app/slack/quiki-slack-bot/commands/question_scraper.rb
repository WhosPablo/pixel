class Expressions
  IGNORE = /(meet)|(tomorrow)|(today)|(yesterday)|(lunch)/
end

module QuikiBot
  module Commands
    class Question < SlackRubyBot::Commands::Base
      match(/[\s\S]*[\?]/)

      def self.call(client, data, _match)

        logger.info "Question scrapped: #{client.owner}, team=#{data.team}, channel=#{data.channel} ,user=#{data.user}, match=#{_match}"

        channel = SlackChannel.find_or_create_by(channel_id: data.channel, team_id: data.team)

        # Do not auto answer for channels that have requested it be turned off
        unless channel.auto_answer
          unless data.user.blank?
          team = SlackTeam.find_by_team_id(data.team)
            full_client =  Slack::Web::Client.new
            full_client.token = team.token

            creator = SlackQaJobHelper.find_user_by_slack_id(full_client, data.user)

            SlackQuestionIndex.create(team_id: data.team, channel_id: data.channel, body: _match, user: creator)
          end
          return
        end

        text = _match.to_s

        # Create a parser object
        tgr = EngTagger.new

        words = tgr.get_words(text)

        unless words.keys.count == 0 or data.user.blank? or text.downcase =~ Expressions::IGNORE

          team = SlackTeam.find_by_team_id(data.team)

          full_client =  Slack::Web::Client.new
          full_client.token = team.token

          creator = SlackQaJobHelper.find_user_by_slack_id(full_client, data.user)

          new_question = SlackQaJobHelper.create_question(creator, text, team.company)

          message = SlackQaJobHelper.find_question_and_confirm(text, team.company, new_question)

          full_client.chat_postMessage(channel: data.channel, text: message[:text], attachments: message[:attachments])

          SlackQaJobHelper.populate_question(data.user, data.team, data.channel, new_question, full_client)
        end
      end
    end
  end
end
