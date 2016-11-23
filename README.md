# S3 Access Checker

This project will enumerate all the IAM Users, Groups, and Roles in an account and test s3:GetObject, s3:PutObject, and s3:DeleteObject permissions for each entity. Only entities that are allowed to perform the specific actions against a specific bucket are listed in the report, along with a reference to which statement (within a Policy) is providing the permission.

## Prerequisites
- AWS credentials file setup with a named profile
- AWS Profile specified has necessary permissions to check IAM entities
- Running in Mac OSX

## Installation and Use

**NOTE: These instructions assume that a Mac is being used. This project has not been tested on Linux/Windows yet.**

### pip
This project is developed using Python in a VirtualEnv environment. To run this project do the following:
- Verify pip is installed on your system (command used to check provided below)
```
pip --version
```

### virtualenv
virtualenv is a way to isolate "Python environments" to avoid possible dependency conflicts. This project requires the boto3 and termcolor libraries. This requirement can be satisfied in one of two ways: global library installation or virtualenv-based installation.

#### Global Installation

To install the dependencies globally, run the following commands:

```
sudo pip install boto3 termcolor
```

#### Virtualenv Installation

In the root directory of this project (the directory containing this README and src/ directory), run the following:
```
virtualenv venvpy27
source venvpy27/bin/activate
pip install -r requirements.txt
```

To "deactivate" the virtual python environment (at the end of using the script), either close the terminal window or run the following:
```
deactivate
```

### main.py

At the top of the file, there are three variables that need to be set.

- target_bucket_arn
    - This variables is the ARN (or wildcarded ARN) that permissions will be tested against. 
    - Examples:
```
target_bucket_arn="arn:aws:s3:::1strategy-logs/*" # This would test for permissions within the 1strategy-logs bucket
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
python src/main.py
```

## Example Output

```
{
	'status': 'success',
	'roles': {
		'PowerUser': {
			'arn:aws:s3:::1strategy-logs/*': {
				's3:GetObject': {
					'decision': 'allowed',
					'statements': ['role_PowerUser_oneClick_PowerUser_1457471620720 - (3:17)-(8:6)']
				},
				's3:PutObject': {
					'decision': 'allowed',
					'statements': ['role_PowerUser_oneClick_PowerUser_1457471620720 - (3:17)-(8:6)']
				}
			}
		},
		'EMR_EC2_DefaultRole': {
			'arn:aws:s3:::1strategy-logs/*': {
				's3:GetObject': {
					'decision': 'allowed',
					'statements': ['AmazonElasticMapReduceforEC2Role - (3:19)-(30:6)']
				},
				's3:PutObject': {
					'decision': 'allowed',
					'statements': ['AmazonElasticMapReduceforEC2Role - (3:19)-(30:6)']
				}
			}
		},
		'EMR_DefaultRole': {
			'arn:aws:s3:::1strategy-logs/*': {
				's3:GetObject': {
					'decision': 'allowed',
					'statements': ['AmazonElasticMapReduceRole - (3:19)-(61:6)']
				}
			}
		},
		'WebServer': {
			'arn:aws:s3:::1strategy-logs/*': {
				's3:GetObject': {
					'decision': 'allowed',
					'statements': ['AmazonS3FullAccess - (3:17)-(8:6)']
				},
				's3:PutObject': {
					'decision': 'allowed',
					'statements': ['AmazonS3FullAccess - (3:17)-(8:6)']
				}
			}
		}
	},
	'report_generated': '2016-06-09 17:29:22',
	'users': {
		'Jordan': {
			'arn:aws:s3:::1strategy-logs/*': {
				's3:GetObject': {
					'decision': 'allowed',
					'statements': ['AdministratorAccess - (3:17)-(8:6)']
				},
				's3:PutObject': {
					'decision': 'allowed',
					'statements': ['AdministratorAccess - (3:17)-(8:6)']
				}
			}
		}
	},
	'groups': {
		'Administrators': {
			'arn:aws:s3:::1strategy-logs/*': {
				's3:GetObject': {
					'decision': 'allowed',
					'statements': ['AdministratorAccess - (3:17)-(8:6)']
				},
				's3:PutObject': {
					'decision': 'allowed',
					'statements': ['AdministratorAccess - (3:17)-(8:6)']
				}
			}
		}
	}
}
```

## Future Enhancements
- Accepting command-line arguments
- Testing/Support for Windows
- Validation on parameters