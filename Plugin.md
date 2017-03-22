# プラグインの管理

## プラグインのインストール方法
jenkinsの公式docker-イメージは、Dockerfileと同階層のディレクトリにある
plugins.txtにインストールしたいプラグインを羅列することにより、jenkinsにプラグインをインストールすることができる。  
「weseek/docker-jenkins」イメージは公式イメージを踏襲しているため、同様の手順を踏む。

`plugins.txtの詳細については、docker-hubの公式イメージからInstalling more toolsの項目を参照`
https://hub.docker.com/_/jenkins/

 plugin.txtに記載するプラグイン名は、プラグイン公式wikiにある「Plugin ID」の値を記載する。  
例「Publish Over SSH Plugin」Plugin ID:publish-over-ssh
https://wiki.jenkins-ci.org/display/JENKINS/Publish+Over+SSH+Plugin
```  plugin.txt
publish-over-ssh:1.14
```

## プラグインのアップデート
git クローン後、ディレクトリ直下にあるplugins.txtを修正する。

### 修正前
```  plugin.txt
publish-over-ssh:1.14
```
###  修正後
``` plugin.txt
publish-over-ssh:1.17
```
バージョン指定したい場合、プラグイン名:X.XX の形式にする。
`※バージョン指定しない場合は、最新バージョンがインストールされる。`

## 既存のjenkinsからplugin一覧を取得する方法

既存jenkinsから、plugin.txt形式の一覧を取得するには以下のコマンドをたたく必要がある。  
`ユーザー認証が必要ない場合は、-u $USER_NAME:$API_TOKENの設定値は必要がなし。`
``` .sh
$ curl -X GET -u $USER_NAME:$API_TOKEN -sSL "$JENKINS_URL:$JENKINS_PORT/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/'
```

### APIトークンの取得手順
1.  jenkins管理画面ログイン
1.  右上のユーザー名をクリック語、メニューから設定（Configure）をクリック
1.  プロフィール画面から、「APIトークンの表示」をクリック
