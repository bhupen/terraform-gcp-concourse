#!/bin/bash -v

sudo -u ubuntu ssh-keygen -t rsa -f /home/ubuntu/.ssh/id_rsa -N '' 
sudo -u ubuntu gsutil cp /home/ubuntu/.ssh/id_rsa.pub gs://${keys_bucket}/
wget https://github.com/concourse/fly/releases/download/${concourse_version}-rc.17/fly_linux_amd64 -O /usr/local/bin/fly
chmod +x /usr/local/bin/fly
