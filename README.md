# Setup
## Configure docker-compose.yml
* AWSでPollyのフルアクセス権限があるIAMユーザを作成、AccessKey/Secretを発行
* Discordの開発者ポータルからBot用のトークンを発行、Botを利用したいチャンネルに参加させる
* 上記情報を元に, `docker-compose.yml` を修正する
  * 対象チャンネルは `- TTS_CHANNELS=#channel1,#channel2,#channel3` のように記述

## Run container
```
docker-build
docker-compose up -d
```

# Command
以下コマンドをdiscordのテキストチャットで実行できます
* `!connect`
    * 現在接続しているボイスチャンネルに読み上げBOTを接続します
* `!destroy`
    * 現在接続しているボイスチャンネルから読み上げBOTを切断します
* `!chname [呼ばれたい名前]`
    * 読み上げる際に、 `XXXXいわく` という説明が入ります。その際の `XXXX` を変更できます
