#!/bin/bash -v

cd /home/ubuntu

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/${concourse_version}/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

while [ `gsutil ls gs://${keys_bucket}/keys/web/tsa_host_key | grep tsa_host_key.pub -c` -eq 0 ]
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

/usr/local/bin/concourse worker \
--work-dir /opt/concourse/worker \
--tsa-host ${tsa_host} \
--tsa-port ${tsa_port} \
--tsa-public-key /home/ubuntu/keys/worker/tsa_host_key.pub \
--tsa-worker-private-key /home/ubuntu/keys/worker/worker_key \
2>&1 > /var/log/concourse_worker.log &