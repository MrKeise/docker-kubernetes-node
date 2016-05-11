FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

#Runit
#RUN apt -y update
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Proxy needs iptables
RUN apt-get install -y iptables

#Need this for ovs-ovsctl
RUN apt-get install -y openvswitch-switch

#Dnsmasq and Confd used for DNS
RUN apt-get install -y dnsmasq 
RUN wget -O /usr/local/bin/confd  https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 && \
    chmod +x /usr/local/bin/confd

#Docker client only
RUN curl -sSL -O https://get.docker.com/builds/Linux/x86_64/docker-1.11.1.tgz && sudo tar zxf docker-1.11.1.tgz -C / && \
    mv docker/docker /usr/local/bin && \
    rm -rf /docker && \
    chmod +x /usr/local/bin/docker

#Kubernetes
RUN wget -O - https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v1.1.3/kubernetes.tar.gz| tar zx
RUN tar -xvf /kubernetes/server/kubernetes-server-linux-amd64.tar.gz --strip-components 3 -C /usr/local/bin 

#Manifests
RUN mkdir -p /etc/kubernetes/manifests

#OVS Scripts
ADD ovs-sync.sh /ovs-sync.sh
ADD ovs-remote.sh /ovs-remote.sh
ADD ovs-show.sh /ovs-show.sh

#Aliases
ADD aliases /root/.aliases
RUN echo "source ~/.aliases" >> /root/.bashrc

#Configs
ADD etc /etc/

#Add runit services
ADD sv /etc/service 

