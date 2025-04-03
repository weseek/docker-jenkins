# イメージで使う Jenkins のアップデート方法

1. リポジトリをクローン
    - https://github.com/weseek/docker-jenkins.git
1. git クローン後、ディレクトリ直下にあるDockerfileを修正する
    - 「FROM jenkins:X.XX.X」の部分を修正
    - 最新バージョンはdocker-hubの公式イメージから参照する
        - https://hub.docker.com/r/_/jenkins/

``` Dockerfile
FROM jenkins:2.32.2
```

## docker-jenkins イメージの更新
- Dockerfile又はplugins.txtファイルを書き換え後、リポジトリにpushを行う
- tag が push されたことを検知して GitHub Actions の release workflow が起動するようになっている
    - `.github/workflows/release.yml` を参考にすること

### git コミットにタグを追加する方法
- タグ名は、jenkinsLTSのバージョンに追従すること
- jenkinsLTSのバージョンが2.32.2の場合、コミットタグは「2.32.2」と入力する
    - 同じバージョンで複数のタグを打ちたい場合には 2.32.2-1 とする
- push後、下記のURLからイメージが更新されたことを確認
    - https://hub.docker.com/r/weseek/docker-jenkins/~/dockerfile/

## dockerコンテナの更新
管理されているホストにログインし、下記コマンドを実行して最新イメージをpull

```
$ docker pull  weseek/docker-jenkins
```

dockerイメージ更新後、下記コマンド実行して、既存コンテナを削除
```
$ docker rm jenkins_app_1 -f
```

下記コマンドを実行し、コンテナを新規作成する
```
$ sudo systemctl start docker-compose@jenkins.service
```

ホスト上のjenkinsにアクセスし、アップデートされたことを確認する
