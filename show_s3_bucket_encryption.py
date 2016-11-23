#!/usr/bin/env python

import boto3


s3 = boto3.resource('s3')
bucket = s3.Bucket('prd-datalake')
for obj in bucket.objects.all():
    key = s3.Object(bucket.name, obj.key)
    #print bucket.name
    print "Bucket Name: %s" % bucket.name
    #print obj.key
    print "File Name: %s" % obj.key
    #print key.server_side_encryption
    print "File is encrypted with: %s" % key.server_side_encryption
    #print key.content_length
    print "File length: %s" % key.content_length
    print " "
    #print obj.get()['Body'].read()
    #print obj.get(IfMatch='names')['Body'].read()

