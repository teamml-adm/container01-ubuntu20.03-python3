# コンテナイメージ名 : ubuntu20.04-python3
- update date: 2022/01/09

## スペック
- OS : Ubuntu20.04
- ユーザ： operator (sudo権限付き)
- 日本語ロケール設定済み
- 開発言語: Python3.8
- インストール済みライブラリ
    - pip
    - awscli v2

## ファイル構成
```
.
├── Dockerfile
├── ctrl-container.sh
└── env.txt
```
- Dockerfile
  コンテナイメージ作成定義ファイル
- ctrl-container.sh
  コンテナ操作スクリプト
- env.txt
  コンテナに渡す定義ファイル

## コンテナ操作スクリプト
ctrl-container.sh<br>
にコンテナを統一的に操作するスクリプトを準備しています。
```
コンテナをビルドする
$ bash ctrl-container.sh build

コンテナを起動する
$ bash ctrl-container.sh start

コンテナを停止する
$ bash ctrl-container.sh stop

コンテナを再起動する
$ bash ctrl-container.sh restart

コンテナ内にログインする
$ bash ctrl-container.sh login

コンテナをECRにpushする
$ bash ctrl-container.sh push

ECS タスクに登録処理を行う前のドライラン(試行)
エラーが出ずにJSON形式の出力があることを確認する
$ bash ctrl-container.sh ecs_dryrun

ECS タスクに登録処理を行う
$ bash ctrl-container.sh ecs
```
