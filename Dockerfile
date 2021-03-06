FROM centos:centos6

MAINTAINER chroju

ENV PATH=/home/develop/.rbenv/bin/:$PATH

RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum update -y
RUN yum install -y ansible sudo passwd openssh-server openssh-clients

RUN useradd develop
RUN echo "develop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

CMD ["ansible", "--version"]
CMD export 

