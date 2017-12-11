FROM jenkins/jenkins:2.73.3-slim
MAINTAINER Yusuke Takagi <heatwave.takagi@gmail.com> 

ARG user=jenkins
ENV DEBIAN_FRONTEND noninteractive

USER root

# install prerequirement tools, and upgrade
RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends gnupg apt-utils apt-transport-https \
 && rm -rf /var/lib/apt/lists/*

# add an apt repository of chrome
# google-chrome.list will be overwritten by installing google-chrome-stabe
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# install several packages for CI
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends google-chrome-stable xvfb sudo fonts-vlgothic mercurial \
  && rm -rf /var/lib/apt/lists/*

# link japanese font in java
RUN mkdir -p /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback
RUN ln -s /usr/share/fonts/truetype/vlgothic/VL-PGothic-Regular.ttf /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback/

# fix loading JFreeChart
# see: https://stackoverflow.com/questions/21841269/performance-graphs-on-jenkins-causing-could-not-initialize-class-org-jfree-char#comment76900079_41428450
RUN sed -i 's/^assistive_technologies=/#&/' /etc/java-8-openjdk/accessibility.properties

# setup sudo
RUN sed -i -e 's/%sudo\s*ALL=(ALL:ALL)\sALL/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
RUN usermod -aG sudo ${user}

# set timezone to JST
RUN rm -f /etc/localtime
RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure tzdata

# install jenkins plugin
USER ${user}
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN cat /usr/share/jenkins/plugins.txt | xargs /usr/local/bin/install-plugins.sh
