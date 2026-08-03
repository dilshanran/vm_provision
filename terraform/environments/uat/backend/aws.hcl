bucket         = "unix-team-terraform-state"
key            = "vm-provision/uat/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "unix-team-terraform-locks"
