#!/bin/bash -v

cd /home/ubuntu

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/${concourse_version}/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

sudo -u ubuntu gsutil cp gs://${keys_bucket}/id_rsa.pub /home/ubuntu/.ssh/authorized_keys

while [ `gsutil ls gs://${keys_bucket}/keys/web | grep tsa_host_key.pub -c` -eq 0 ]
do
    echo "sleeping"
    sleep 10
done

mkdir /home/ubuntu/keys
gsutil cp -r gs://${keys_bucket}/keys/* /home/ubuntu/keys

mkdir -p /opt/concourse/worker

touch /var/log/concourse_worker.log
chmod 666 /var/log/concourse_worker.log

export CONCOURSE_BAGGAGECLAIM_DRIVER="native"

gcloud iam service-accounts keys create /home/ubuntu/key.json --iam-account terraform@${project_id}.iam.gserviceaccount.com

apt-get update
apt-get --assume-yes install jq
apt-get clean 

export GIT_PASS_KEY=`cat /home/ubuntu/key.json | jq -r -c '.' | sed -e 's/\"/\\\"/g'`

sudo /usr/local/bin/concourse worker \
--work-dir /opt/concourse/worker \
--tsa-host ${tsa_host}:2222 \
--tsa-public-key /home/ubuntu/keys/worker/tsa_host_key.pub \
--tsa-worker-private-key /home/ubuntu/keys/worker/worker_key \
2>&1 > /var/log/concourse_worker.log &
