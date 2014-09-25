#!/bin/bash


#
#
# This script is designed for AWS - Ubuntu 14.04-LTS and installs:
# Java 7, ActiveMQ, Tomcat 7
#
# Authors: rlarubbio, fhuster, koshalt
#
#


set -e



echo "***** MOTECH Machine Preparation"

echo "*** Java 7 ***"
apt-get -y -qq install python-software-properties 1>/dev/null
add-apt-repository --yes ppa:webupd8team/java 1>/dev/null
apt-get -y -qq update
# Set some vars so the oracle installer doesn't ask us to accept the license
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get -y -qq install oracle-java7-installer
echo "export JAVA_OPTS=\"-Xms1024m -Xmx2048m -XX:MaxPermSize=1024m\"" >> ~/.profile
echo "export CATALINA_OPTS=\"-Xms1024m -Xmx2048m -XX:MaxPermSize=1024m\"" >> ~/.profile
source ~/.profile
echo "*** Java 7 installation complete ***"


echo "*** ActiveMQ ***"
if [ ! -h /etc/activemq/instances-enabled/main ]; then
        apt-get -y -qq install activemq 1>/dev/null
        ln -s /etc/activemq/instances-available/main /etc/activemq/instances-enabled/main
        service activemq start        
fi
echo "*** ActiveMQ installation complete ***"


echo "*** Tomcat 7 ***"
if [ ! -f /etc/init.d/tomcat7 ]; then		
		mkdir -p ~/tomcat
        cd ~/tomcat
        wget -q http://apache.cs.utah.edu/tomcat/tomcat-7/v7.0.55/bin/apache-tomcat-7.0.55.tar.gz
        tar xzf apache-tomcat-7.0.55.tar.gz
        sed -i 's/<\/tomcat-users>/  <user username=\"motech\" password=\"motech\" roles=\"manager-gui\"\/>\n&/' ~/tomcat/apache-tomcat-7.0.55/conf/tomcat-users.xml
        ln -s ~/tomcat/apache-tomcat-7.0.55 ~/tomcat/tomcat7
        printf "export CATALINA_HOME=/home/ubuntu/tomcat/tomcat7" >> ~/.profile        

        
        echo "case \$1 in start)
			sh /home/ubuntu/tomcat/tomcat7/bin/startup.sh
			;;
			stop) 
			sh /home/ubuntu/tomcat/tomcat7/bin/shutdown.sh
			;;
			restart)
			sh /home/ubuntu/tomcat/tomcat7/bin/shutdown.sh
			sh /home/ubuntu/tomcat/tomcat7/bin/startup.sh
			;;
			esac 
			exit 0
			" > /etc/init.d/tomcat7
        chmod 755 /etc/init.d/tomcat7
        update-rc.d tomcat7 defaults 1>/dev/null   
        chown -R ubuntu.ubuntu ~/tomcat
        su -c "service tomcat7 start" ubuntu
fi
echo "*** Tomcat 7 installation complete ***"


echo "*** Creating felix-cache directory ***"
mkdir -p ~/felix-cache
chown -R ubuntu.ubuntu ~/felix-cache
echo "*** Creating .motech & bundles directory ***"
mkdir -p ~/.motech/bundles
chown -R ubuntu.ubuntu ~/.motech

echo "** All done. Let's go to WAR!! ***"