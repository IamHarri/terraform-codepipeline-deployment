#!/bin/bash
sudo yum update
sudo yum install -y wget ruby nginx
cd /home/ec2-user
wget https://aws-codedeploy-${aws_region}.s3.${aws_region}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
systemctl start codedeploy-agent

mkdir -p /var/www/angular_app

echo "$(cat <<EOM
server {
  listen 80;
  listen [::]:80;
  root /var/www/angular_app;
  server_name _;
  location / {
    index index.html;
    try_files \$uri \$uri/ /index.html =404;
  }
}
EOM
)" > /etc/nginx/conf.d/default.conf

service nginx restart