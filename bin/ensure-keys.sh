#!/bin/sh
# 幫 crontab 裡每個 run-job.sh 工作先產生 deploy key（已存在就跳過），方便在第一次執行前就登記到 GitHub。
set -eu
grep -o 'run-job\.sh [^ ]* [^ ]*' /collector/repo/crontab | while read -r _ name repo; do
  key=/collector/keys/${name}_ed25519
  [ -f "$key" ] && continue
  ssh-keygen -q -t ed25519 -N '' -C "nas-collector:$name" -f "$key"
  echo "$(date '+%F %T') 新 deploy key：${key}.pub → https://github.com/$repo/settings/keys（勾 Allow write access）" >> /collector/logs/collector.log
done
