# spotcha

Spot game server and manager chat bot

これはGoogle Cloud + Discordを活用したゲームサーバ構築のためのテンプレートです。

使う方はForkするなりして好きにいじってください。

## 前提

- Google Cloudの知識があること
- Google Cloudのプロジェクトを持っていること
- Github Actionsがわかること
- terraformがわかること
- DiscordのInteraction Endpointの登録ができること

## How to use

作ったVMをDiscordであげたり落としたりすることで費用節約しつつサーバを管理できます

<img width="518" alt="スクリーンショット 2024-09-18 11 45 13" src="https://github.com/user-attachments/assets/c06f180b-daa8-4a4e-a21b-7781284ae946">

VMの作成はterraform or 手動を想定。将来的にはBot経由でそれもできるようにするかもしれない。


## 準備

### 1. Google Cloud編

- プロジェクト取得
- terraform用Bucket作成
- デプロイ用SA発行
- JSON Key発行

### 2. Github Actions編

- Workflowsの各所修正
- Secret設定

### 3. terraform編

- 必要な箇所の修正

### 4. Discord bot編

- Interaction Endpoint Applicationの登録
- Secert ManagerへのPublic Keyの登録
- Botのデプロイ

## 参考

- [Discord のコマンド (Application Commands) を AWS CDK + AWS Lambda で実装してみた](https://dev.classmethod.jp/articles/discord-application-commands-aws-lambda-aws-cdk/)
- [Discord Interaction Endpoint を多段 Lambda 構成にしてタイムアウトを回避する](https://dev.classmethod.jp/articles/discord-interaction-endpoint-deferred-multi-lambda/)
