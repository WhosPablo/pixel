require 'celluloid/current'

require 'slack-ruby-bot'

require_relative 'quiki-slack-bot/client'
require_relative 'quiki-slack-bot/info'

# require_relative 'quiki-slack-bot/commands/base'
require_relative '../../app/jobs/common/slack_qa_job_helper'
require_relative 'quiki-slack-bot/commands/help'
require_relative 'quiki-slack-bot/commands/defaults'
require_relative 'quiki-slack-bot/commands/question_scraper'
#


require 'server'
require 'app'
require 'config'
require 'service'
