#!/bin/bash -v

sudo -u ubuntu ssh-keygen -t rsa -f /home/ubuntu/.ssh/id_rsa -N '' 
sudo -u ubuntu gsutil cp /home/ubuntu/.ssh/id_rsa.pub gs://${keys_bucket}/
wget -q -O - --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jre-8u161-linux-x64.tar.gz"|tar -xzf - --directory=/etc/alternatives
update-alternatives --install /usr/bin/java java /etc/alternatives/jre1.8.0_161/bin/java 1
wget -q -O -  https://download.sonatype.com/nexus/3/latest-unix.tar.gz|tar -xzf - --directory=/opt
sed -i -e"s/application-port=8081/application-port=80/" /opt/nexus-3.10.0-04/etc/nexus-default.properties
sudo ln -s /opt/nexus-3.10.0-04/bin/nexus /etc/init.d/nexus
sudo update-rc.d nexus defaults
sudo service nexus start
