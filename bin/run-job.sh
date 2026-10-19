#!/bin/sh
# 用法：run-job.sh <工作名稱> <GitHub repo，例如 jsdryan/xxx> <在 repo 根目錄執行的指令>
# 每個工作用自己的 deploy key（/collector/keys/<名稱>_ed25519，第一次執行時自動產生），
# 只能推那一個 repo。執行完把 repo 內的變更 commit 並 push。
set -eu
name=$1; repo=$2; cmd=$3
key=/collector/keys/${name}_ed25519
log=/collector/logs/${name}.log
work=/collector/work/$name
exec >> "$log" 2>&1
echo "=== $(date '+%F %T') start"

if [ ! -f "$key" ]; then
  ssh-keygen -q -t ed25519 -N '' -C "nas-collector:$name" -f "$key"
  echo "新產生 deploy key，請把 ${key}.pub 加到 https://github.com/$repo/settings/keys（勾 Allow write access）"
fi
tmpkey=$(mktemp); cp "$key" "$tmpkey"; chmod 600 "$tmpkey"
trap 'rm -f "$tmpkey"' EXIT
export GIT_SSH_COMMAND="ssh -i $tmpkey -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/collector/keys/known_hosts"

if [ ! -d "$work/.git" ]; then
  git clone -q "git@github.com:$repo.git" "$work"
fi
cd "$work"
git config user.name "nas-collector"
git config user.email "nas-collector@users.noreply.github.com"
git fetch -q origin
git reset -q --hard origin/HEAD

sh -c "$cmd"

git add -A
if git diff --cached --quiet; then
  echo "no changes"
else
  git commit -q -m "自動更新 $name $(date '+%F %H:%M')（NAS）"
  git push -q origin HEAD
  echo "pushed $(git rev-parse --short HEAD)"
fi
echo "=== $(date '+%F %T') done"
