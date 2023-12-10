require 'active_support/all'
require 'dotenv/load'
require 'date'

require_relative 'github/api_client'
require_relative 'google_spread_sheet/api_client'
require_relative 'slack/api_client'

class CommentCollecter
  def initialize
    @github_client = ::GitHub::ApiClient.new(
      ENV['GITHUB_UNAME'],
      ENV['GITHUB_TOKEN'],
      ENV['REPO_OWNER'],
      ENV['REPO_NAME']
    )
    @sheets_client = ::GoogleSpreadSheet::ApiClient.new(ENV['CLIENT_SECRET_PATH'])
    @slack_client = ::Slack::ApiClient.new(ENV['SLACK_BOT_USER_AOUTH_TOKEN'])
  end

  def execute
    begin      
      pr_comments = @github_client.fetch_pr_comments
      values = pr_comments.map { |comment| [comment[:content], comment[:url]] }
      write_flg = @sheets_client.write_to_spreadsheet(values)
      
      slack_notify(pr_comments) if write_flg
      puts 'success'
    rescue => e
      puts "error occur: #{e.message}"
    end
  end

  private

  def slack_notify(pr_comments)
    if pr_comments.present?
      @slack_client.post_message(
        "##{ENV['SLACK_CHANNEL']}",
        "今スプリントに作成したプルリクエストへのレビューコメントがGoogle Sheetsに書き込みが完了しました。\n振り返りを行ってください。\n#{ENV['SPREAD_SHEET_BASE_URL']}/#{ENV['SPREAD_SHEET_KEY']}/edit#gid=0")
    elsif pr_comments.empty?
      @slack_client.post_message("##{ENV['SLACK_CHANNEL']}", '今スプリントはプルリクエストへのレビューコメントが0件でした。')
    else
      raise 'slackへの通知に失敗しました。'
    end
  end
end
