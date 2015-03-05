FROM cern/slc6-lite
MAINTAINER Adrien Devresse

# update repositories
RUN yum update -y

#install davix
RUN yum install davix -y

# install repos for the data bridge
RUN davix-get http://grid-deployment.web.cern.ch/grid-deployment/dms/lcgutil/repos/lcgutil-continuous-el6.repo /etc/yum.repos.d/lcgutil-continuous-el6.repo
RUN davix-get http://svn.cern.ch/guest/lcgdm/extras/build/repos/lcgdm-cbuilds-relcand-el6.repo /etc/yum.repos.d/lcgdm-cbuilds-relcand-el6.repo


# install rsyslog + dynafed + davix plugin + httpd 
RUN yum install rsyslog dynafed-http-plugin.x86_64 dynafed.x86_64 dynafed-dmlite-frontend.x86_64 -y


# install memcached and mod_ssl
RUN yum install memcached mod_ssl -y


## disable the mod_dav module 
RUN sed -i 's/LoadModule dav/#LoadModule dav/g' /etc/httpd/conf/httpd.conf 

## switch httpd to mpm event
RUN sed -i 's@^#HTTPD=.*@HTTPD=/usr/sbin/httpd.event@g' /etc/sysconfig/httpd

## rename path properly
RUN sed -i 's@/myfed@/db/dav@g' /etc/ugr.conf
RUN sed -i 's@/myfed@/db/dav@g' /etc/httpd/conf.d/zlcgdm-ugr-dav.conf

# add init script
COPY start-databridge /usr/bin/start-databridge
RUN chmod 755 /usr/bin/start-databridge

# expose data bridge ports
EXPOSE 80
EXPOSE 443


ENTRYPOINT ["start-databridge"]



