require 'google_drive'
require 'dotenv/load'

# @param [String] credentials_path 認証情報のパス
#
# @return [Boolean] スプレッドシートへの書き込みが成功したかどうか
module GoogleSpreadSheet
  class ApiClient
    class AuthorizeError < StandardError; end

    INIT_SHEET_NAME = 'シート1'

    def initialize(credentials_path)
      @credentials_path = credentials_path
    end

    def write_to_spreadsheet(values)
      begin
        # Google ドライブに接続
        session = GoogleDrive::Session.from_service_account_key(@credentials_path)
        raise AuthorizeError unless session
        
        # ワークシート生成
        work_sheet = generate_worksheet(session)
        
        # データを書き込み
        header = ['コメント', 'URL', 'カテゴリ']
        data = [header] + values
        data.each_with_index do |value, i|
          work_sheet[i + 1, 1] = value[0]
          work_sheet[i + 1, 2] = value[1]
          work_sheet[i + 1, 3] = value[2] if value[2].present?
        end
        return unless work_sheet.save
        
        true
      rescue GoogleDrive::Error => e
        raise "スプレッドシートへの書き込みに失敗しました: #{e.message}"
      rescue Google::Apis::ClientError => e
        raise "スプレッドシートへのリクエスト制限に達しました。: #{e.message}"
      rescue AuthorizeError => e
        raise "認証に失敗しました: #{e.message}"
      end
    end

    private

    def generate_worksheet(session)
      current_date = Time.now.strftime('%Y%m%d')
      work_sheet_name = "#{current_date}_efo_pr_comments"

      # 既存のスプレッドシートを取得
      sheet = session.spreadsheet_by_key(ENV['SPREAD_SHEET_KEY'])

      work_sheet = sheet.worksheet_by_title(INIT_SHEET_NAME)
      if work_sheet.nil?
        # シート1が存在しない場合は、ワークシートを新規作成
        work_sheet = sheet.add_worksheet(work_sheet_name)
      else
        # シート1が存在する場合は、ワークシート名を変更
        work_sheet.title = work_sheet_name
        work_sheet.save
      end

      work_sheet
    end
  end
end
