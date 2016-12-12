module SlackRubyBotServer
  class App
    def prepare!
      mark_teams_active!
      update_team_name_and_id!
      purge_inactive_teams!
    end

    def self.instance
      @instance ||= new
    end

    private

    def logger
      @logger ||= begin
        $stdout.sync = true
        Logger.new(STDOUT)
      end
    end

    def mark_teams_active!
      SlackTeam.where(active: nil).update_all(active: true)
    end

    def update_team_name_and_id!
      SlackTeam.active.where(team_id: nil).each do |team|
        begin
          auth = team.ping![:auth]
          team.update_attributes!(team_id: auth['team_id'], name: auth['team'])
        rescue StandardError => e
          logger.warn "Error pinging team #{team.id}: #{e.message}."
          team.set(active: false)
        end
      end
    end

    def purge_inactive_teams!
      SlackTeam.purge!
    end

    # def configure_global_aliases!
    #   SlackRubyBot.configure do |config|
    #     config.aliases = ENV['SLACK_RUBY_BOT_ALIASES'].split(' ') if ENV['SLACK_RUBY_BOT_ALIASES']
    #   end
    # end
  end
end
