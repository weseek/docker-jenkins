# 起動方法

## docker インストール
`公式サイトを参照`  
https://docs.docker.com/engine/installation/linux/

## docker-compose インストール
`公式サイトを参照`  
https://docs.docker.com/compose/install/

## systemctl 起動コマンドの設定

下記パスにdocker-compose設定ファイルを保存する。
```/etc/docker-compose/jenkins.yml
version: "3"

services:
  app:
    image: "weseek/docker-jenkins"
    ports:
      - "0.0.0.0:8080:8080"
    #If you want to use jenkins slave(jnlp) port, uncomment this line
    #- "50000:50000"
    volumes:
     - "var_jenkins_home:/var/jenkins_home"
volumes:
  var_jenkins_home:
```

下記コマンドを実行。
```
 $ sudo wget https://gist.githubusercontent.com/skomma/c4514e84b6a1dcd22d31516f7acc9c2e/raw/da1e16ec4cfec91984b0d52305240bff1b57e259/docker-compose@.service -O /etc/systemd/system/docker-compose@.service
```
/etc/systemd/system/docker-compose@.service
に保存される。

##  jenkins 起動コマンド
下記コマンド実行後、jenkinsコンテナが立ち上がる。
```
$ sudo systemctl start docker-compose@jenkins.service
```

## jenkins インストール
設定したホストのアドレスに接続。
https://XXX.XXX.XXX.XXX:8080

jenkinsは初期インストール時にパスワードを入力する必要がある。

### 下記コマンドを入力し、パスワードを表示
```
$ docker exec jenkins_app_1 cat /var/jenkins_home/secrets/initialAdminPassword 
5ba9301c65994efab809eafb6e54a760
```
「Select plugins to install」を選択後、次画面の「None」をクリックし、インストールを実行する。

<img width="749.25" alt="screenshot_none.png (158.5 kB)" src="https://img.esa.io/uploads/production/attachments/5207/2017/02/22/17362/664bcc45-58a4-411d-ba6a-8618d9725497.png">

※dockerイメージに記載されているplugin.txtにすべてのプラグインが記載されているためインストールしたいプラグインを選択する必要はなし。

## インストールプラグインの確認
インストール後ユーザー登録画面が表示される。画面下部「Continue as admin」ボタンを押し、「Start using Jenkins」で
jenkinsが立ち上がる。

`※ユーザーは作成しなくても、管理画面に遷移することは可能。「admin:初期パスワード」でログインが可能。`

その後「Jenkinsの管理」から、「プラグインの管理」でインストール済みのプラグインを確認し、
docker-imageで設定されたプラグインがすべてインストールされていることを確認。