set -e

apt-get update

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update
apt-get install -y mongodb-org=4.4.* mongodb-org-server=4.4.* mongodb-org-shell=4.4.* mongodb-org-mongos=4.4.* mongodb-org-tools=4.4.*

apt-mark hold mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools

sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

cat >> /etc/mongod.conf <<EOF

security:
  authorization: enabled
EOF

systemctl enable mongod
systemctl start mongod

sleep 10

mongo admin --eval "db.createUser({user: 'admin', pwd: '${mongo_password}', roles: [{role: 'root', db: 'admin'}]})"

mongo admin -u admin -p ${mongo_password} --eval "
use tododb;
db.createUser({
  user: 'todoapp',
  pwd: '${mongo_password}',
  roles: [{ role: 'readWrite', db: 'tododb' }]
});
"

apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update
apt-get install -y google-cloud-sdk


#Create Backup Script
cat > /home/ubuntu/backup-mongodb.sh <<'SCRIPT'
#!/bin/bash
DATE=$(date +"%Y-%m-%d")
BACKUP_DIR="/tmp/mongodb-backup-$DATE"
MONGO_PASSWORD="${mongo_password}"
BUCKET_NAME="${bucket_name}"


mongodump --username admin --password "$MONGO_PASSWORD" --authenticationDatabase admin --out "$BACKUP_DIR"

tar -czf /tmp/mongodb-backup-$DATE.tar.gz -C /tmp "mongodb-backup-$DATE"

gsutil cp /tmp/mongodb-backup-$DATE.tar.gz gs://$BUCKET_NAME/

rm -rf "$BACKUP_DIR" /tmp/mongodb-backup-$DATE.tar.gz

echo "Backup Completed: backup-mongodb-$DATE.tar.gz uploaded to gs://$BUCKET_NAME/"

SCRIPT

chmod +x /home/ubuntu/backup-mongodb.sh
chown ubuntu:ubuntu /home/ubuntu/backup-mongodb.sh

echo "0 2 * * * /home/ubuntu/backup-mongodb.sh >> /var/log/mongodb-backup.log 2>&1" | crontab -u ubuntu -

su - ubuntu -c "/home/ubuntu/backup-mongodb.sh"

echo "MongoDB installation and configuration competed successfully."
