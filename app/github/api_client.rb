require_relative 'config'

# @param [String] uname GitHubのユーザー名
# @param [String] token GitHubのアクセストークン
# @param [String] repo_owner リポジトリのオーナー名
# @param [String] repo_name リポジトリ名
# @param [Date] period フィルタリングする期間
#
# @return [Array<Hash>] コメントハッシュ { content, url } を要素として持つ配列
module GitHub
  class ApiClient
    START_DATE = Date.today
    END_DATE = START_DATE - 14

    def initialize(uname, token, repo_owner, repo_name, period = nil)
      @uname = uname
      @token = token
      @repo_owner = repo_owner
      @repo_name = repo_name

      GitHub::Config.configure(@token) # Octokit.configure を呼び出す
    end
    
    def fetch_pr_comments
      assigned_pull_requests = fetch_assigned_prs

      filterd_by_period_prs = filter_prs_by_period(assigned_pull_requests, START_DATE, END_DATE)
      extract_reviewer_comments(filterd_by_period_prs)
    end

    private

    # 自分がアサインされたプルリクエストを取得
    def fetch_assigned_prs
      page = 1
      assigned_prs = []

      loop do
        prs = Octokit.issues(
          "#{@repo_owner}/#{@repo_name}",
          assignee: @uname,
          state: 'all',
          sort: 'updated',
          page: page,
          per_page: 100,
        )

        break if prs.empty?
        assigned_prs.concat(prs)
        page += 1
      end

      assigned_prs
    end

    # 期間を指定してプルリクエストをフィルタリング
    def filter_prs_by_period(prs, start_date, end_date)
      prs.select do |pr|
        created_at = Date.parse(pr.created_at.to_s)
        start_date <= created_at && created_at < (end_date + 1)
      end
    end

    # プルリクエストからレビューコメントを抽出
    def extract_reviewer_comments(prs)
      comments = []
      prs.each_slice(30) do |sliced_prs|
        pr_nums = sliced_prs.map { |pr| pr[:number] }
        pr_nums.each do |pr_num|
          pr_comments = Octokit.pull_request_comments("#{@repo_owner}/#{@repo_name}", pr_num)

          # 自分以外のコメントだけをフィルタリング
          reviewer_comments = pr_comments.reject { |c| c.user.login == @uname }
          reviewer_comments = reviewer_comments.map do |c|
            { content: c.body, url: c.html_url }
          end
          comments.concat(reviewer_comments)
        end
      end

      comments
    end
  end
end
