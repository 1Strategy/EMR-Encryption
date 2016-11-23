#!/usr/bin/env python

import boto3

s3 = boto3.resource('s3')
bucket = s3.Bucket('prd-datalake')
for obj in bucket.objects.filter(Prefix='names-data/').limit(count=2):
    print "%s %s" % (bucket.name, obj.key)
    print obj.get()['Body'].read()

