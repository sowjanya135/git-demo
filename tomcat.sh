#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.0.8/bin/apache-tomcat-10.0.8.tar.gz
sudo tar xvf apache-tomcat-10.0.8.tar.gz
sudo mkdir /opt/tomcat/
sudo mv apache-tomcat-10.0.8/ /opt/tomcat/
sudo useradd tomcat
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R 755 /opt/tomcat/
sudo chown -R tomcat:tomcat /etc/systemd
#sudo echo CATALINA_HOME=/opt/tomcat >> /etc/systemd/system/tomcat.service
#sudo export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.13.0.8-1.amzn2.0.3.x86_64 >> /etc/systemd/system/tomcat.service
#sudo export ExecStart=/opt/tomcat/bin/startup.sh >> /etc/systemd/system/tomcat.service
#sudo export ExecStart=/opt/tomcat/bin/shutdown.sh >> /etc/systemd/system/tomcat.service
sudo cp /home/ec2-user/env-var /etc/systemd/system/tomcat.service
sudo systemctl daemon-reload
sudo /opt/tomcat/apache-tomcat-10.0.8/bin/startup.sh
