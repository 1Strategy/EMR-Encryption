#!/bin/bash

# The following script downloads a bundle of configuration files and
# keystores from a given s3 location provided as argument.

if [ $# -lt 1 ]; then
  echo "Usage $0 <s3 location>"
  echo "e.g. $0 s3://foo/"
fi

KEYSTORE_NAME=keystore.jks
TRUSTSTORE_NAME=truststore.jks
CLIENT_SSL_CONFIG=ssl-client.xml
SERVER_SSL_CONFIG=ssl-server.xml

LOCAL_SECURITY_BASE_DIR=/etc/emr/security
LOCAL_KEYSTORE_DIR=$LOCAL_SECURITY_BASE_DIR/ssl
LOCAL_CONFIG_DIR=$LOCAL_SECURITY_BASE_DIR/conf

function setup_directory {

  local directory=${1}
  sudo mkdir -p $directory
}

function download_resource {

  if [ $# -lt 2 ]; then
    echo "Not enough arguments to properly download the resource."
    exit -1
  fi

  local remote_resource=${1}
  local local_resource=${2}

  sudo aws s3 cp $remote_resource $local_resource
  if [ $? -ne 0 ]; then
    exit $?
  fi
}

echo "Creating directory $LOCAL_KEYSTORE_DIR..."
setup_directory $LOCAL_KEYSTORE_DIR

echo "Downloading secrets..."
download_resource $1/$KEYSTORE_NAME $LOCAL_KEYSTORE_DIR
download_resource $1/$TRUSTSTORE_NAME $LOCAL_KEYSTORE_DIR

echo "Creating directory $LOCAL_CONFIG_DIR..."
setup_directory $LOCAL_CONFIG_DIR

echo "Downloading configurations..."
download_resource $1/$CLIENT_SSL_CONFIG $LOCAL_CONFIG_DIR
download_resource $1/$SERVER_SSL_CONFIG $LOCAL_CONFIG_DIR

exit $?
