#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage $0 <s3 location>"
  echo "e.g. $0 s3://foo/"
fi

SSL_CLIENT_CONF_FILE=conf/ssl-client.xml
SSL_SERVER_CONF_FILE=conf/ssl-server.xml
KEYSTORE_FILE=security/keystore.jks
TRUSTSTORE_FILE=security/truststore.jks
VOLUME_ENCRYPTION_SCRIPT=volume-encryption.sh
DISTRIBUTE_KEYSTORE_SCRIPT=distribute-keystore.sh

function upload_resource {

  local local_resource=${1}
  local remote_resource=${2}

  if [ ! -f $local_resource ]; then
    echo "$local_resource doesn't exists."
    exit -1
  fi

  aws s3 cp $local_resource $remote_resource

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

# Uploading resources:
upload_resource $SSL_CLIENT_CONF_FILE $1
upload_resource $SSL_SERVER_CONF_FILE $1
upload_resource $KEYSTORE_FILE $1
upload_resource $TRUSTSTORE_FILE $1
upload_resource $VOLUME_ENCRYPTION_SCRIPT $1
upload_resource $DISTRIBUTE_KEYSTORE_SCRIPT $1
