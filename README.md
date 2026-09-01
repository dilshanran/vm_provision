# vm_provision

Multi-cloud VM provisioning with Terraform and GitHub Actions (**AWS** and **Azure**).

## Docs

- **[CI/CD Guide (A to Z )](docs/CI-CD-GUIDE.md)** — GitHub, Actions, AWS, Azure, flows, and step-by-step runs

## Quick start (local)

```bash
cd terraform/environments/dev

# AWS
../../scripts/init-backend.sh aws
terraform plan -var-file=terraform_aws.tfvars

# Azure
../../scripts/init-backend.sh azure
terraform plan -var-file=terraform.tfvars
```

## Quick start (CI)

1. Open **Actions → Terraform → Run workflow**
2. Choose `action`, `environment`, and `cloud` (`aws` or `azure`)
3. Ensure Environment secrets `TF_VARS_AWS` and `TF_VARS_AZURE` are set

## Layout

| Path | Purpose |
|------|---------|
| `terraform/environments/*` | Per-env roots (`dev`, `stage`, `uat`, `prod`) |
| `terraform/modules/vm` | Shared module (AWS or Azure child) |
| `.github/workflows` | Plan/apply/destroy, drift, PR checks |
