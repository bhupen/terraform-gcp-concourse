#!/bin/bash -v

cd /home/ubuntu

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/${concourse_version}/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

sudo -u ubuntu gsutil cp gs://${keys_bucket}/id_rsa.pub /home/ubuntu/.ssh/authorized_keys

if [ `gsutil ls gs://${keys_bucket}/keys/web/tsa_host_key | grep tsa_host_key.pub -c` -eq 0 ]; then
    mkdir -p keys/web keys/worker

    ssh-keygen -t rsa -f /home/ubuntu/keys/web/tsa_host_key -N ''
    ssh-keygen -t rsa -f /home/ubuntu/keys/web/session_signing_key -N ''

    ssh-keygen -t rsa -f /home/ubuntu/keys/worker/worker_key -N ''

    cp /home/ubuntu/keys/worker/worker_key.pub /home/ubuntu/keys/web/authorized_worker_keys
    cp /home/ubuntu/keys/web/tsa_host_key.pub /home/ubuntu/keys/worker

    gsutil cp -r /home/ubuntu/keys gs://${keys_bucket}/
else
    mkdir /home/ubuntu/keys
    gsutil cp -r gs://${keys_bucket}/keys/* /home/ubuntu/keys
fi

if [ ! -f /home/ubuntu/key.json ]; then
    gcloud iam service-accounts keys create /home/ubuntu/key.json --iam-account concourse-proxy@${project_id}.iam.gserviceaccount.com
fi

gsutil ls gs://concourse-3b4acc437c1053fa/
if [ ! -f ssl_cert/concourse-web.csr ]; then
    mkdir ssl_cert
    openssl genrsa -out ssl_cert/concourse-web.key 2048
    openssl req -new -key ssl_cert/concourse-web.key -out ssl_cert/concourse-web.csr <<EOF
US
Illinois
Chicago
CNA
CNAX
xpteam
CNAXDevTeam@cnahardy.com
XP5432xp

EOF
    openssl x509 -req -days 365 -in ssl_cert/concourse-web.csr -signkey ssl_cert/concourse-web.key -out ssl_cert/concourse-web.crt
fi

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /home/ubuntu/cloud_sql_proxy
chmod +x /home/ubuntu/cloud_sql_proxy
touch /var/log/sql-proxy.log
chmod 666 /var/log/sql-proxy.log
/home/ubuntu/cloud_sql_proxy -instances=${project_id}:${region}:${database_identifier}=tcp:5432,${project_id}:${region}:${database_replica}=tcp:5433 -credential_file=/home/ubuntu/key.json 1>/var/log/sql-proxy.log 2>&1 &

touch /var/log/concourse-web.log
chmod 666 /var/log/concourse-web.log

if [ ! -f /home/ubuntu/startup.sh ]; then
cat <<FILE >/home/ubuntu/startup.sh
#!/bin/bash -v
/usr/local/bin/concourse web \
--basic-auth-username myuser \
--basic-auth-password mypass \
--session-signing-key /home/ubuntu/keys/web/session_signing_key \
--tsa-host-key /home/ubuntu/keys/web/tsa_host_key \
--tsa-authorized-keys /home/ubuntu/keys/web/authorized_worker_keys \
--postgres-data-source postgres://${database_username}:${database_password}@localhost:5432/${database_name}?sslmode=disable \
--tls-bind-port=443 \
--tls-cert=/home/ubuntu/ssl_cert/concourse-web.crt \
--tls-key=/home/ubuntu/ssl_cert/concourse-web.key \
--external-url ${external-url} \
--peer-url http://$(hostname -I) \
2>&1 > /var/log/concourse-web.log
reboot
FILE
fi

chmod 700 /home/ubuntu/startup.sh
/home/ubuntu/startup.sh &
