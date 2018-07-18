#!/bin/bash -ex
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
#VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --output text --query 'Vpcs[].VpcId')
VPC_ID="vpc-be490eda"
# curl http://169.254.169.254/latest/meta-data/instance-id && echo
INSTANCE_ID="i-0a148dec064fc841c"

#private IP
#curl http://169.254.169.254/latest/meta-data/local-ipv4 && echo
PRIVATE_IP="172.28.159.34"
APP_PORT="8080"

# curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone && echo
AVAILABILITY_ZONE="us-east-1d"

ROLE_NAME="k8s-container-default"
ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/k8s-container-default"

minikube start --extra-config=apiserver.authorization-mode=RBAC
# makes dashboard play nice with rbac
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

# allows magic-ip to list pods and play nice with rbac
kubectl create clusterrolebinding default-cluster-admin --clusterrole=cluster-admin --serviceaccount=default:default

# necessary for fake-ec2metadata-ds.yaml
kubectl create secret generic aws-configuration --from-file=config=$HOME/.aws/config --from-file=credentials=$HOME/.aws/credentials

# necessary for aws-mock-ds.yaml
kubectl create secret generic aws-creds --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

# Pick *ONE* of the following two. aws-mock-ds.yaml requires modification!
kubectl apply -f fake-ec2metadata-ds.yaml
# kubectl apply -f aws-mock-ds.yaml
kubectl apply -f magic-ip-ds.yaml
