# Terraform Configuration for ECS with API gateway

This repository contains Terraform configuration files to set up an EC2 instance with a Flask server. The configuration includes creating a VPC, public subnet, security group, IAM role, and EC2 instance.

## Prerequisites

- Terraform >= 1.5
- AWS account with access keys
- SSH key pair for accessing the EC2 instance

## Configuration

### Variables

The following variables need to be set in a `terraform.tfvars` file or passed as command-line arguments:

- `aws_access_key`: Your AWS access key
- `aws_secret_key`: Your AWS secret key
- `key_name`: The name of your SSH key pair

### Example `terraform.tfvars`

```hcl
aws_access_key = "your-aws-access-key"
aws_secret_key = "your-aws-secret-key"
key_name       = "your-key-name"