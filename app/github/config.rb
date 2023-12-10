require 'octokit'

module GitHub
  class Config
    class << self
      def configure(access_token)
        Octokit.configure do |c|
          c.access_token = access_token
        end
      end
    end
  end
end
