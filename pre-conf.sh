#!/bin/bash

#reason of this script is that dockerfile only execute one command at the time but we need sometimes at the moment we create 
#the docker image to run more that one software for expecified configuration like when you need mysql running to chnage or create
#database for the container ...

 useradd --system --home /usr/local/nagios -M nagios
 groupadd --system nagcmd
 usermod -a -G nagcmd nagios
 usermod -a -G nagcmd www-data
 cd /tmp
 wget http://switch.dl.sourceforge.net/project/nagios/nagios-4.x/nagios-4.0.8/nagios-4.0.8.tar.gz
 wget http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz
 tar -xvf nagios-4.0.8.tar.gz
 tar -xvf nagios-plugins-2.0.3.tar.gz
 
 #installing nagios
 cd /tmp/nagios-4.0.8
  ./configure --with-nagios-group=nagios --with-command-group=nagcmd --with-mail=/usr/sbin/sendmail --with-httpd_conf=/etc/apache2/conf-available
  make all
  make install
  make install-init
  make install-config
  make install-commandmode
  make install-webconf
  cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
  chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
  /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
  ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios
  
  #installing plugins 
  cd /tmp/nagios-plugins-2.0.3/
  ./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-perl-modules --enable-extra-opts
  make
  make install
  
  a2enmod cgi
  # need to pass password .. with no interactive
  htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
  
  # need to add this to file /etc/apache2/sites-enabled/000-default.conf
  Include conf-available/nagios.conf
  
  rm -rf /tmp/* /var/tmp/* 
