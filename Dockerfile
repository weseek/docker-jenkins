FROM jenkins:2.46.1
MAINTAINER Yusuke Takagi <heatwave.takagi@gmail.com> 

USER root
ARG user=jenkins
ENV DEBIAN_FRONTEND noninteractive

# chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# apt install && update
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y google-chrome-stable xvfb sudo fonts-vlgothic
# update mercurial from backports for TLS SNI support
RUN apt-get -y -t jessie-backports install mercurial
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# font
RUN mkdir -p /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback
RUN ln -s /usr/share/fonts/truetype/vlgothic/VL-PGothic-Regular.ttf /usr/lib/jvm/java-8-openjdk-amd64/jre/font/fallback/

# sudo
RUN sed -i -e 's/%sudo\s*ALL=(ALL:ALL)\sALL/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
RUN usermod -aG sudo ${user}

# timezone
RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure tzdata

# jenkins plugin
USER ${user}
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN cat /usr/share/jenkins/plugins.txt | xargs /usr/local/bin/install-plugins.sh
