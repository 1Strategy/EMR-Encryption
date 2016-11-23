#!/bin/bash

if [ -e security ]; then
  rm -rf security
fi

# Creating temporary working dir
mkdir security

keytool -genkeypair -alias Cluster -keyalg RSA -keysize 1024 -keypass {{ emr_keystore_password }} -keystore security/keystore.jks -storepass {{ emr_truststore_password }} -dname "CN=*.{{ aws_region }}.compute.internal, OU=EMR, O=AWS, L=Seattle, ST=Washington, C=US"
keytool -exportcert -keystore security/keystore.jks -alias Cluster -storepass {{ emr_truststore_password }} -file security/cluster.cer
keytool -importcert -keystore security/truststore.jks -alias Cluster -storepass {{ emr_truststore_password }} -file security/cluster.cer -noprompt
