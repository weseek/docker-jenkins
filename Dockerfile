FROM jenkins/jenkins:2.206-slim
MAINTAINER Yusuke Takagi <heatwave.takagi@gmail.com> 

ARG user=jenkins
ENV DEBIAN_FRONTEND noninteractive

ARG DOCKER_CLI_VERSION=18.06.1-ce
ARG DOCKER_HOST_GID=999

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

# install docker client
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLI_VERSION}.tgz | tar -xz -C /tmp \
  && mv /tmp/docker/docker /usr/local/bin \
  && rm -r /tmp/docker*
RUN groupadd -g ${DOCKER_HOST_GID} docker
RUN usermod -aG docker jenkins

# link japanese font in java
RUN mkdir -p ${JAVA_HOME}/jre/lib/fonts/fallback
RUN ln -s /usr/share/fonts/truetype/vlgothic/VL-PGothic-Regular.ttf ${JAVA_HOME}/jre/lib/fonts/fallback

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
