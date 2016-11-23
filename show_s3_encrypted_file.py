#!/usr/bin/env python

import boto3

s3 = boto3.resource('s3')
bucket = s3.Bucket('aaron-test-bucket-00')
for obj in bucket.objects.filter(Prefix='names-enc/'):
    #print "%s %s" % (bucket.name, obj.key)
    print obj.get()['Body'].read()

