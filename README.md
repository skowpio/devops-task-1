# Usage

## Pre-requirements 

1. Define instance type and AWS region

```
values/development-task-hr-eu-west-1.tfvars
```

File has got region in name, just in case someone would like to deploy that onto multi-regions. 


2. Create ssh key-pair on AWS in the region, which you choose 
3. Create AMI user with access to the AWS API, for the purpose of this exercises it was quite wide - AdministratorAccess 

## Deploy infrastructure

```
terraform init -reconfigure

terraform plan -var-file values/development-task-hr-eu-west-1.tfvars -var="aws_access_key=XXXXXXXX" -var="aws_secret_key=YYYYYYYYYYYYYYYYYYYYY" -out plan.out

terraform apply plan.out
```

## Checks 

1. Access bastion host via ssh 

```
ssh -i ~/.ssh/xapo-interview.pem  ec2-user@<BASTION_PUBLIC_IP>

```
2. Check out index.html on both nginx nodes 

```
curl -q -s http://<NGINX_1_PRIVATE_IP>
```
3. 

```
curl -q -s http://<NGINX_2_PRIVATE_IP>
```

## Improvments - proposal how to make this task even better. 

1. Use s3 as a backend for terraform. 
2. Use DynamoDB table for terraform locking. 
3. Add LoadBalancer in front of nginx. 
