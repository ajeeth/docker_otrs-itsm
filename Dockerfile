FROM centos:7
MAINTAINER Ajeeth Samuel <ajeeth.samuel@gmail.com>

#SYSTEMD centos7
#ENV container docker
#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
#systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*;
#VOLUME [ "/sys/fs/cgroup" ]


RUN yum install -y yum-plugin-fastestmirror && \
    yum install -y epel-release && \
    yum update -y && \
    yum -y install bzip2 cronie openssh-server wget curl mariadb-server mariadb httpd httpd-devel mysql mod_perl \
    perl-core "perl(Crypt::SSLeay)" "perl(Net::LDAP)" "perl(URI)" \
    procmail "perl(Date::Format)" "perl(LWP::UserAgent)" \
    "perl(Net::DNS)" "perl(IO::Socket::SSL)" "perl(XML::Parser)" \
    "perl(Apache2::Reload)" "perl(Crypt::Eksblowfish::Bcrypt)" \
    "perl(Encode::HanExtra)" "perl(GD)" "perl(GD::Text)" "perl(GD::Graph)" \
    "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(PDF::API2)" "perl(DateTime)" \
    "perl(Text::CSV_XS)" "perl(YAML::XS)" "perl(Text::CSV_XS)" "perl(DBD::mysql)" \
    rsyslog supervisor tar which && \
    yum install -y https://ftp.otrs.org/pub/otrs/RPMS/rhel/7/otrs-6.0.26-01.noarch.rpm && \
    /opt/otrs/bin/otrs.CheckModules.pl && \
    yum clean all

#MYSQL
RUN sed -i '/user=mysql/akey_buffer_size=32M' /etc/my.cnf
RUN sed -i '/user=mysql/amax_allowed_packet=32M' /etc/my.cnf

#OTRS
#RUN wget https://ftp.otrs.org/pub/otrs/RPMS/rhel/7/otrs-6.0.26-01.noarch.rpm
#RUN yum -y install otrs-6.0.26-01.noarch.rpm --skip-broken

#OTRS COPY Configs
ADD Config.pm /opt/otrs/Kernel/Config.pm
RUN sed -i -e "s/mod_perl.c/mod_perl.so/" /etc/httpd/conf.d/zzz_otrs.conf

#Get ITSM module
RUN wget https://ftp.otrs.org/pub/otrs/itsm/bundle6/ITSM-6.0.26.opm

#reconfigure httpd
RUN sed -i "s/error\/noindex.html/otrs\/index.pl/" /etc/httpd/conf.d/welcome.conf

#Start web and otrs and configure mysql
ADD firstrun.sh /firstrun.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN touch /firstrun

#set up sshd
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd

#enable crons
WORKDIR /opt/otrs/var/cron/
USER otrs
CMD ["/bin/bash -c 'for foo in *.dist; do cp $foo `basename $foo .dist`; done'"]

USER root
EXPOSE 22 80
CMD ["/bin/bash", "/run.sh"]
