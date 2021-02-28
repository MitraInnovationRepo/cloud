#!/bin/sh
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
BUCKET=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/BUCKET" -H "Metadata-Flavor: Google")

gsutil cp gs://${BUCKET}/server-info.jar .
gsutil cp gs://${BUCKET}/jdk-11.tar.xz .
tar -xf jdk-11.tar.xz
export JAVA_HOME=/jdk-11
export PATH=$PATH:$JAVA_HOME/bin
java -jar server-info.jar