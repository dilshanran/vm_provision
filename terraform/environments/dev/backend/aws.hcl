# AWS remote state (S3 + DynamoDB lock)
# Selected by: ../../scripts/init-backend.sh aws

bucket         = "unix-team-terraform-newstate"
key            = "vm-provision/dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "unix-team-terraform-locks"
