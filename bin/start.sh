#!/bin/sh
# 容器進入點：安裝排程後讓 crond 常駐。
set -eu
mkdir -p /collector/keys /collector/work /collector/logs
crontab /collector/repo/crontab
sh /collector/repo/bin/ensure-keys.sh >> /collector/logs/collector.log 2>&1 || true
echo "$(date '+%F %T') collector started @ $(git -C /collector/repo rev-parse --short HEAD)" >> /collector/logs/collector.log
exec crond -f -l 8
