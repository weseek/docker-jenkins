# イメージで使う Jenkins のアップデート方法

## weseek/docker-jenkins
githubに管理されているリポジトリからクローン。  
https://github.com/weseek/docker-jenkins.git

## jenkins のアップデート方法
git クローン後、ディレクトリ直下にあるDockerfileを修正する。  
`「FROM jenkins:X.XX.X」の部分を修正。`

最新バージョンはdocker-hubの公式イメージから参照する。  
https://hub.docker.com/r/_/jenkins/

``` Dockerfile
FROM jenkins:2.32.1
USER root
ARG user=jenkins

# chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# apt install && update
RUN apt-get update && apt-get install -y google-chrome-stable xvfb sudo fonts-vlgothic
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#font
RUN mkdir -p /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback
RUN ln -s /usr/share/fonts/truetype/vlgothic/VL-PGothic-Regular.ttf /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback/

# sudo
RUN sed -i -e 's/%sudo\s*ALL=(ALL:ALL)\sALL/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
RUN usermod -aG sudo ${user}

# jenkins plugin
USER ${user}
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
```

## docker-jenkins イメージの更新
Dockerfile又はplugins.txtファイルを書き換え後、リポジトリにpushを行う。  
`尚pushの際には、コミットログにタグを必ず普及する。`

### git コミットにタグを追加する方法
https://git-scm.com/book/ja/v1/Git-%E3%81%AE%E5%9F%BA%E6%9C%AC-%E3%82%BF%E3%82%B

push後、下記のURLからイメージが更新されたことを確認。  
https://hub.docker.com/r/weseek/docker-jenkins/~/dockerfile/

## dockerコンテナの更新
管理されているホストにログインし、下記コマンドを実行して最新イメージをpull。

```
$ docker pull  weseek/docker-jenkins
```
dockerイメージ更新後、下記コマンド実行して、既存コンテナを削除。
```
$ docker rm jenkins_app_1 -f
```

下記コマンドを実行し、コンテナを新規作成する。
```
$ sudo systemctl start docker-compose@jenkins.service
```
ホスト上のjenkinsにアクセスし、アップデートされたことを確認する。
