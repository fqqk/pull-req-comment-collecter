require 'slack-ruby-client'

# @param [String] token SlackのBot User OAuth Token
module Slack
  class ApiClient
    def initialize(token)
      Slack.configure { |config| config.token = token }
      @client = Slack::Web::Client.new
    end

    def post_message(channel, text)
      @client.chat_postMessage(channel: channel, text: text)
    end
  end
end
