#!/bin/sh
# 每小時：拉最新的 nas-collector，排程有變就重新載入。
set -eu
cd /collector/repo
before=$(git rev-parse HEAD)
git pull -q --ff-only
after=$(git rev-parse HEAD)
if [ "$before" != "$after" ]; then
  crontab /collector/repo/crontab
  echo "$(date '+%F %T') updated ${before%${before#???????}} -> ${after%${after#???????}}" >> /collector/logs/collector.log
fi
