# pull-req-comment-collecter

## brew install
```
brew install libhttp-parser
brew install http-parser
```

## create .env
```
# GitGub
GITHUB_TOKEN=your_token
GITHUB_UNAME=your_name
REPO_OWNER=owner
REPO_NAME=repo_name

# Google Spreadsheet
CLIENT_SECRET_PATH=config/credentials.json # ref: https://qiita.com/kaito-h/items/15b4808011afeb36df5c
SPREAD_SHEET_KEY=your_sheet_key # e.g. https://docs.google.com/spreadsheets/d/[your_sheet_key]
SPREAD_SHEET_BASE_URL=https://docs.google.com/spreadsheets/d

# Slack
SLACK_BOT_USER_AOUTH_TOKEN=your_bot_token # ref: https://qiita.com/kobayashi_ryo/items/a194e620b49edad27364
SLACK_CHANNEL=your_channel_name
```

## how to execute
```
$ cd your_dir/pull-req-comment-collecter
$ chmod +x script.sh
$ ./script.sh
```

## setting cron
```
crontab -e

2週間に一回月曜日の場合
0 17 * * 1 [ $(( $(date +\%s) / 60 / 60 / 24 / 7 \% 2)) -eq 0 ] && /path/to/your/script.sh
```