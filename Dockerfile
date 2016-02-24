# Build:
#   docker build -t mattcahill/ubuntu-foreman .
#
# Run:
#  docker run -d -P --name=ubuntu-foreman -h foreman.example.com mattcahill/ubuntu-foreman
#
# tail log:
#   docker logs -f ubuntu-foreman
#
# get port 443 exposed on host
#  docker port ubuntu-foreman 443
#
# Used the following projects as reference:
#   riskable/docker-foreman
#   xnaveira/foreman-docker
# 
# This project used a fork of gbevan/ubuntu-foreman as a starting point
#
# Please report issues via github

FROM ubuntu:latest
MAINTAINER Matt Cahill

ENV DEBIAN_FRONTEND noninteractive
ENV FOREOPTS --foreman-proxy-tftp=false \
        --foreman-unattended=false \
        --enable-puppet \
        --puppet-listen=true \
        --puppet-show-diff=true \
        --puppet-server-envs-dir=/etc/puppet/environments

RUN apt-get update && \
    apt-get -y install ca-certificates wget && \
    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    dpkg -i puppetlabs-release-trusty.deb && \
    apt-get install -y aptitude htop vim vim-puppet git traceroute dnsutils && \
    echo "deb http://deb.theforeman.org/ trusty 1.10" > /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ plugins 1.10" >> /etc/apt/sources.list.d/foreman.list && \
    wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && \
    apt-get update && \
    apt-get install -y foreman-installer \
    software-properties-common \
    python-pip && \
    echo "set modeline" > /root/.vimrc && \
    echo "export TERM=vt100" >> /root/.bashrc && \
    LANG=en_US.UTF-8 locale-gen --purge en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales

EXPOSE 443
EXPOSE 8140
EXPOSE 8443

CMD ( test ! -f /var/lib/foreman/.first_run_completed && \
        ( echo "FIRST-RUN: Please wait while Foreman is installed and configured..."; \
        /usr/sbin/foreman-installer $FOREOPTS; \
        sed -i -e "s/START=no/START=yes/g" /etc/default/foreman; \
        touch /var/lib/foreman/.first_run_completed \
        ) \
    ); \
    /etc/init.d/puppet stop && \
    /etc/init.d/apache2 stop && \
    /etc/init.d/foreman stop && \
    /etc/init.d/postgresql stop && \
    sleep 60 && \
    /etc/init.d/postgresql start && \
    sleep 60 && \
    /etc/init.d/foreman start && \
    /etc/init.d/apache2 start && \
    /etc/init.d/puppet start && \
    /etc/init.d/foreman-proxy start && \
    /usr/sbin/cron && \
    tail -f /var/log/foreman/production.log
