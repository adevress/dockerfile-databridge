FROM centos:6
MAINTAINER Adrien Devresse


# install repos for the data bridge
#RUN davix-get http://grid-deployment.web.cern.ch/grid-deployment/dms/lcgutil/repos/lcgutil-continuous-el6.repo /etc/yum.repos.d/lcgutil-continuous-el6.repo
RUN curl -L http://svn.cern.ch/guest/lcgdm/extras/build/repos/lcgdm-cbuilds-relcand-el6.repo -o /etc/yum.repos.d/lcgdm-cbuilds-relcand-el6.repo \
    && curl -L https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -o /tmp/epel.rpm \
    && rpm -ivh /tmp/epel.rpm


# install rsyslog + dynafed + davix plugin + httpd 
RUN yum install rsyslog \
	dynafed-http-plugin.x86_64 \
	dynafed.x86_64 dynafed-dmlite-frontend.x86_64  \
	mod_ssl \
	-y

## do a bit of tuning
## - disable the mod_dav module 
## - configure to mpm event for performance
## - add support for memcached docker
RUN sed -i 's/LoadModule dav/#LoadModule dav/g' /etc/httpd/conf/httpd.conf \
  && sed -i 's@^#HTTPD=.*@HTTPD=/usr/sbin/httpd.event@g' /etc/sysconfig/httpd \
  && sed -i 's@127.0.0.1:11211@memcache:11211@' /etc/ugr.conf


# add init script
COPY start-databridge /usr/bin/start-databridge
RUN chmod 755 /usr/bin/start-databridge

# expose data bridge ports
EXPOSE 80
EXPOSE 443


ENTRYPOINT ["start-databridge"]



