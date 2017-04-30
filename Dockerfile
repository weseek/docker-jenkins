FROM jenkins:2.46.2
MAINTAINER Yusuke Takagi <heatwave.takagi@gmail.com> 

ARG user=jenkins
ENV DEBIAN_FRONTEND noninteractive

USER root

# add an apt repository of chrome
# google-chrome.list will be overwritten by installing google-chrome-stabe
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# install and update several packages for CI
# update mercurial from backports for TLS SNI support
RUN apt-get update \
  && apt-get install -y --no-install-recommends apt-utils apt-transport-https \
  && apt-get install -y --no-install-recommends google-chrome-stable xvfb sudo fonts-vlgothic \
  && apt-get install -y --no-install-recommends -t jessie-backports mercurial \
  && rm -rf /var/lib/apt/lists/*

# link japanese font in java
RUN mkdir -p /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback
RUN ln -s /usr/share/fonts/truetype/vlgothic/VL-PGothic-Regular.ttf /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback/

# setup sudo
RUN sed -i -e 's/%sudo\s*ALL=(ALL:ALL)\sALL/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
RUN usermod -aG sudo ${user}

# set timezone to JST
RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure tzdata

# install jenkins plugin
USER ${user}
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN cat /usr/share/jenkins/plugins.txt | xargs /usr/local/bin/install-plugins.sh
