# nas-collector

家裡 Synology DS923+ 上常駐的資料蒐集容器（Container Manager 專案 `collector`）。
用途：需要台灣 IP、或需要每天固定跑的蒐集工作，抓完推回各自的 GitHub repo。

## 結構
- NAS `/volume1/docker/collector/`
  - `compose.yaml`：本 repo 的 `compose.yaml` 複本（唯一需要手動放到 NAS 的檔案）
  - `repo/`：本 repo，容器啟動時 clone、每小時 `self-update.sh` 自動 pull
  - `keys/`：每個工作一把 deploy key（私鑰只在 NAS），`known_hosts`
  - `work/<工作>/`：各工作的 repo checkout
  - `logs/`：`collector.log`、`<工作>.log`

## 新增一個蒐集工作
1. 在目標 repo 寫好會更新檔案的指令（容器是 python:3.12-alpine，只有標準函式庫；需要套件就在指令裡 `pip install`）。
2. 在 `crontab` 加一行 `run-job.sh <名稱> <owner/repo> "<指令>"`，push。
3. 一小時內 NAS 會載入；第一次執行會在 `keys/<名稱>_ed25519.pub` 產生公鑰，把它加到目標 repo 的 Deploy keys（勾 write）。

## 工作清單
| 名稱 | repo | 時間 |
|---|---|---|
| xinzhuang-jobs | jsdryan/xinzhuang-kindergarten-jobs | 每天 06:30 |
