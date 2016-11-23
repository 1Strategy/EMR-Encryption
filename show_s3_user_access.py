#!/usr/bin/env python
import datetime
from termcolor import colored
import boto3
import json

target_bucket_arn="arn:aws:s3:::prd-datalake-demo/*"
aws_profile_name="admin"
s3_permissions_to_test=["s3:GetObject","s3:PutObject","s3:DeleteObject"]

def main():
    print colored("Initializing check...", 'yellow')
    
    aws_session = boto3.Session(profile_name=aws_profile_name)
    iam = aws_session.client('iam')
    
    print "Processing IAM Users..."
    
    users = iam.list_users()
           
    result = { "users":{}, "groups":{}, "roles":{} }
    
    for user in users["Users"]:
        print colored("\tProcessing {}...".format(user["UserName"]), "yellow")
        
        sim_response = iam.simulate_principal_policy(
            PolicySourceArn=user["Arn"],
            ActionNames=s3_permissions_to_test,
            ResourceArns=[
                target_bucket_arn
            ]
        )
        
        result["users"][user["UserName"]] = {}
        
        for result_item in sim_response["EvaluationResults"]:
            if result_item["EvalDecision"] != "allowed":
                continue
                
            if not result["users"][user["UserName"]].get(result_item["EvalResourceName"]):
                result["users"][user["UserName"]][result_item["EvalResourceName"]] = {}
                
            result["users"][user["UserName"]][result_item["EvalResourceName"]][result_item["EvalActionName"]] = {"decision": result_item["EvalDecision"], "statements":[]}
            
            for matched_statement in result_item["MatchedStatements"]:
                item = "{} - ({}:{})-({}:{})".format(
                    matched_statement["SourcePolicyId"],
                    matched_statement["StartPosition"]["Line"],
                    matched_statement["StartPosition"]["Column"],
                    matched_statement["EndPosition"]["Line"],
                    matched_statement["EndPosition"]["Column"]) 
                
                result["users"][user["UserName"]][result_item["EvalResourceName"]][result_item["EvalActionName"]]["statements"].append(item)
                
    
    print "Processing IAM Groups..."
    
    groups = iam.list_groups()
    
    for group in groups["Groups"]:
        print colored("\tProcessing {}...".format(group["GroupName"]), "yellow")
        
        sim_response = iam.simulate_principal_policy(
            PolicySourceArn=group["Arn"],
            ActionNames=s3_permissions_to_test,
            ResourceArns=[
                target_bucket_arn
            ]
        )
        
        result["groups"][group["GroupName"]] = {}
        
        for result_item in sim_response["EvaluationResults"]:
            if result_item["EvalDecision"] != "allowed":
                continue
                
            if not result["groups"][group["GroupName"]].get(result_item["EvalResourceName"]):
                result["groups"][group["GroupName"]][result_item["EvalResourceName"]] = {}
                
            result["groups"][group["GroupName"]][result_item["EvalResourceName"]][result_item["EvalActionName"]] = {"decision": result_item["EvalDecision"], "statements":[]}
            
            for matched_statement in result_item["MatchedStatements"]:
                item = "{} - ({}:{})-({}:{})".format(
                    matched_statement["SourcePolicyId"],
                    matched_statement["StartPosition"]["Line"],
                    matched_statement["StartPosition"]["Column"],
                    matched_statement["EndPosition"]["Line"],
                    matched_statement["EndPosition"]["Column"]) 
                
                result["groups"][group["GroupName"]][result_item["EvalResourceName"]][result_item["EvalActionName"]]["statements"].append(item)
    
    print "Processing IAM Roles..."
    
    roles = iam.list_roles()
    
    for role in roles["Roles"]:
        print colored("\tProcessing {}...".format(role["RoleName"]), "yellow")
        
        sim_response = iam.simulate_principal_policy(
            PolicySourceArn=role["Arn"],
            ActionNames=s3_permissions_to_test,
            ResourceArns=[
                target_bucket_arn
            ]
        )
        
        result["roles"][role["RoleName"]] = {}
        
        for result_item in sim_response["EvaluationResults"]:
            if result_item["EvalDecision"] != "allowed":
                continue
                
            if not result["roles"][role["RoleName"]].get(result_item["EvalResourceName"]):
                result["roles"][role["RoleName"]][result_item["EvalResourceName"]] = {}
                
            result["roles"][role["RoleName"]][result_item["EvalResourceName"]][result_item["EvalActionName"]] = {"decision": result_item["EvalDecision"], "statements":[]}
            
            for matched_statement in result_item["MatchedStatements"]:
                item = "{} - ({}:{})-({}:{})".format(
                    matched_statement["SourcePolicyId"],
                    matched_statement["StartPosition"]["Line"],
                    matched_statement["StartPosition"]["Column"],
                    matched_statement["EndPosition"]["Line"],
                    matched_statement["EndPosition"]["Column"]) 
                
                result["roles"][role["RoleName"]][result_item["EvalResourceName"]][result_item["EvalActionName"]]["statements"].append(item)
    
    result["status"] = "success"
    result["report_generated"] = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
    
    print colored("Report successfully processed.", "green")
    print "Report Output: "
    print ""
    print json.dumps(result, sort_keys=True, indent=4)
    #print result

if __name__ == "__main__":
    main()
