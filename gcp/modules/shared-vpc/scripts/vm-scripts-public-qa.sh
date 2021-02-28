#!/bin/sh
apt-get update
apt-get install apache2 -y
echo "<h1>You are viewing the Public Subnet QA Instance</h1>" > /var/www/html/index.html

PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
BUCKET=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BUCKET" -H "Metadata-Flavor: Google")

echo "Project ID: ${PROJECTID} Bucket: ${BUCKET}"
gsutil cp gs://${BUCKET}/server-info.jar .
gsutil cp gs://${BUCKET}/jdk-11.tar.xz .
tar -xf jdk-11.tar.xz
export JAVA_HOME=/jdk-11
export PATH=$PATH:$JAVA_HOME/bin
java -jar server-info.jar