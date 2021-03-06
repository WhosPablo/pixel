module QuikiBot
  module Commands
    class AnswerPrevious < SlackRubyBot::Commands::Base
      match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)

      def self.call(client, data, _match)
        logger.info "Command in answer previous: #{_match}, user=#{data.user}, channel=#{data.channel}, team=#{data.team}"

        ## Can't guarantee order so to make up for it
        if _match.to_s.include? "answer off" or  _match.to_s.include? "answer on"
          QuikiBot::Commands::AutoAnswer.call(client, data, _match)
          return
        elsif _match.to_s.include? "help"
          QuikiBot::Commands::Help.call(client, data, _match)
          return
        end

        question_index = SlackQuestionIndex.where(team_id: data.team, channel_id: data.channel).last

        unless question_index.body.blank?
          team = SlackTeam.find_by_team_id(data.team)

          full_client =  Slack::Web::Client.new
          full_client.token = team.token

          new_question = SlackQaJobHelper.create_question(question_index.user, question_index.body, team.company)

          message = SlackQaJobHelper.find_question_and_confirm(question_index.body, team.company, new_question)

          full_client.chat_postMessage(channel: data.channel, text: message[:text], attachments: message[:attachments])

          SlackQaJobHelper.populate_question(data.user, data.team, data.channel, new_question, full_client, team.company)
        end
      end
    end
  end
end
