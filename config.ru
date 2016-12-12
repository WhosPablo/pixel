# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require_relative 'app/slack/slack-ruby-bot-server'

Thread.abort_on_exception = true

Thread.new do
  puts "Starting Slack App Bot Server"
  SlackRubyBotServer::App.instance.prepare!
  SlackRubyBotServer::Service.start!
end

run Rails.application
