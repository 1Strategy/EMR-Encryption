# S3 Access Checker

This project will enumerate all the IAM Users, Groups, and Roles in an account and test s3:GetObject, s3:PutObject, and s3:DeleteObject permissions for each entity. Only entities that are allowed to perform the specific actions against a specific bucket are listed in the report, along with a reference to which statement (within a Policy) is providing the permission.

## Prerequisites
- AWS credentials file setup with a named profile
- AWS Profile specified has necessary permissions to check IAM entities
- Running in Mac OSX

### show_s3_user_encryption.py

At the top of the file, there are three variables that need to be set.

- target_bucket_arn
    - This variables is the ARN (or wildcarded ARN) that permissions will be tested against. 
    - Examples:
```
target_bucket_arn="arn:aws:s3:::prd-datalake-demo/*" # This would test for permissions within the prd-datalake-demo bucket
```
- aws_profile_name
    - This variable tells the script which AWS Profile (in the AWS credentials file) should be used. 
- s3_permissions_to_test
    - This variable is an array of AWS Permissions to test against the supplied bucket for each IAM entity.
    - Example:
```
s3_permissions_to_test=["s3:GetObject","s3:PutObject","s3:DeleteObject"]
```

Run the script by executing the following command from the project root directory:
```
python show_s3_bucket_encryption.py
```

## Example Output

```
{
    "groups": {}, 
    "report_generated": "2016-11-23 15:04:59", 
    "roles": {
        "EMR_DefaultRole": {
            "arn:aws:s3:::prd-datalake-demo/*": {
                "s3:GetObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AmazonElasticMapReduceRole - (3:19)-(69:6)"
                    ]
                }
            }
        }, 
        "EMR_EC2_DefaultRole": {
            "arn:aws:s3:::prd-datalake-demo/*": {
                "s3:DeleteObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AmazonElasticMapReduceforEC2Role - (3:19)-(30:6)"
                    ]
                }, 
                "s3:GetObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AmazonElasticMapReduceforEC2Role - (3:19)-(30:6)"
                    ]
                }, 
                "s3:PutObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AmazonElasticMapReduceforEC2Role - (3:19)-(30:6)"
                    ]
                }
            }
        }
    }, 
    "status": "success", 
    "users": {
        "EMR-Encryption-Demo-Denied-User": {}, 
        "EMR-Encryption-Demo-Dev-User": {
            "arn:aws:s3:::prd-datalake-demo/*": {
                "s3:DeleteObject": {
                    "decision": "allowed", 
                    "statements": [
                        "EMR-Encryption-Demo-Dev-Policy - (3:19)-(12:10)"
                    ]
                }, 
                "s3:GetObject": {
                    "decision": "allowed", 
                    "statements": [
                        "EMR-Encryption-Demo-Dev-Policy - (3:19)-(12:10)"
                    ]
                }, 
                "s3:PutObject": {
                    "decision": "allowed", 
                    "statements": [
                        "EMR-Encryption-Demo-Dev-Policy - (3:19)-(12:10)"
                    ]
                }
            }
        }, 
        "EMR-Encryption-Demo-List-User": {}, 
        "EMR-Encryption-Demo-Load-User": {
            "arn:aws:s3:::prd-datalake-demo/*": {
                "s3:PutObject": {
                    "decision": "allowed", 
                    "statements": [
                        "EMR-Encryption-Demo-Load-Policy - (3:19)-(13:10)"
                    ]
                }
            }
        }, 
        "admin": {
            "arn:aws:s3:::prd-datalake-demo/*": {
                "s3:DeleteObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AdministratorAccess - (3:17)-(8:6)"
                    ]
                }, 
                "s3:GetObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AdministratorAccess - (3:17)-(8:6)"
                    ]
                }, 
                "s3:PutObject": {
                    "decision": "allowed", 
                    "statements": [
                        "AdministratorAccess - (3:17)-(8:6)"
                    ]
                }
            }
        }
    }
}

```
