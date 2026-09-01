# VM Provision CI/CD Guide (A to Z)

A practical guide for juniors working on this repository.  
Goal: provision Linux VMs on **AWS** or **Azure** using the **same Terraform code**, driven by **GitHub Actions**.

---

## Table of contents

1. [Big picture](#1-big-picture)
2. [Repository map](#2-repository-map)
3. [GitHub part](#3-github-part)
4. [GitHub Actions part](#4-github-actions-part)
5. [AWS part](#5-aws-part)
6. [Azure part](#6-azure-part)
7. [What is common (both clouds)](#7-what-is-common-both-clouds)
8. [End-to-end flows](#8-end-to-end-flows)
9. [Step-by-step: run a deploy](#9-step-by-step-run-a-deploy)
10. [Step-by-step: switch cloud](#10-step-by-step-switch-cloud)
11. [Troubleshooting](#11-troubleshooting)
12. [Glossary](#12-glossary)

---

## 1. Big picture

```text
  Developer
      |
      |  opens PR / clicks "Run workflow"
      v
 +-----------+       +------------------+
 |  GitHub   | ----> |  GitHub Actions  |
 |  repo +   |       |  (CI/CD runner)  |
 |  Environments     +--------+---------+
 +-----------+                |
                              | OIDC login (no long-lived passwords)
              +---------------+----------------+
              |                                |
              v                                v
        +-----------+                    +-----------+
        |    AWS    |                    |   Azure   |
        | EC2 + S3  |                    | VM + Blob |
        | state     |                    | state     |
        +-----------+                    +-----------+
```

**In one sentence:**  
You choose environment (`dev` / `stage` / `uat` / `prod`) and cloud (`aws` / `azure`). GitHub Actions authenticates with OIDC, loads the matching tfvars secret, initializes the matching Terraform backend, then runs plan / apply / destroy.

---

## 2. Repository map

```text
vm_provision/
├── .github/
│   ├── workflows/
│   │   ├── terraform.yml      # Manual plan / apply / destroy
│   │   ├── drift.yml          # Daily drift check
│   │   └── pr-validation.yml  # Checks on pull requests
│   └── actions/
│       ├── cloud-oidc/        # Login to AWS or Azure
│       ├── write-tfvars/      # Write TF_VARS_* to terraform.tfvars
│       └── terraform-plugin-cache/
└── terraform/
    ├── environments/
    │   ├── dev|stage|uat|prod/
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── versions.tf
    │   │   ├── backend.tf
    │   │   ├── backend/aws.hcl
    │   │   ├── backend/azure.hcl
    │   │   ├── terraform.tfvars.aws.example
    │   │   └── terraform.tfvars.azure.example
    ├── modules/vm/            # Shared module (picks AWS or Azure child)
    │   ├── aws/
    │   └── azure/
    └── scripts/init-backend.sh
```

| Path | Purpose |
|------|---------|
| `terraform/environments/<env>/` | One folder per environment |
| `modules/vm` | Cloud-agnostic entry; calls `aws` or `azure` submodule |
| `backend/aws.hcl` / `backend/azure.hcl` | Where remote state is stored |
| `*.tfvars.*.example` | Templates for GitHub secrets (safe to commit) |
| `terraform_aws.tfvars` / `terraform.tfvars` | Local only (gitignored) |

---

## 3. GitHub part

### 3.1 Environments

GitHub **Environments**: `dev`, `stage`, `uat`, `prod`.

Each environment holds **variables** (non-secret) and **secrets** (sensitive).

### 3.2 Variables (per Environment)

| Variable | Used for |
|----------|----------|
| `AWS_ROLE_ARN` | IAM role for GitHub OIDC (AWS runs) |
| `AWS_REGION` | AWS region (default `us-east-1`) |
| `AZURE_CLIENT_ID` | App registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant |
| `AZURE_SUBSCRIPTION_ID` | Target subscription |

### 3.3 Secrets (per Environment)

| Secret | When used | Contents |
|--------|-----------|----------|
| `TF_VARS_AWS` | `cloud = aws` | Full AWS `terraform.tfvars` text |
| `TF_VARS_AZURE` | `cloud = azure` | Full Azure `terraform.tfvars` text |

You keep **both** secrets on the same Environment. The workflow picks one based on the **cloud** input. No more swapping a single secret.

> Optional legacy: old `TF_VARS` may still exist as fallback. Prefer `TF_VARS_AWS` / `TF_VARS_AZURE`.

### 3.4 What goes in each secret

Copy from examples:

- AWS → `terraform/environments/<env>/terraform.tfvars.aws.example`
- Azure → `terraform/environments/<env>/terraform.tfvars.azure.example`

Then replace placeholders (`subnet-xxxxxxxx`, SSH keys, etc.).

**AWS secret must include:**

```hcl
cloud_provider = "aws"
region         = "us-east-1"
# tags, vms, aws_config ...
```

**Azure secret must include:**

```hcl
cloud_provider = "azure"
region         = "eastus2"
# tags, vms, azure_config ...
```

---

## 4. GitHub Actions part

### 4.1 Workflows

| Workflow | File | Trigger | What it does |
|----------|------|---------|--------------|
| **Terraform** | `terraform.yml` | Manual (`workflow_dispatch`) | plan / apply / destroy |
| **Drift Detection** | `drift.yml` | Daily schedule + manual | Detect config vs state drift |
| **PR Validation** | `pr-validation.yml` | Pull request | fmt, validate, tag checks |

### 4.2 Manual Terraform inputs

When you click **Actions → Terraform → Run workflow**:

| Input | Options | Meaning |
|-------|---------|---------|
| `action` | plan, apply, destroy | What Terraform should do |
| `environment` | dev, stage, uat, prod | Which folder + GitHub Environment |
| `cloud` | azure, aws | Auth, backend, and which `TF_VARS_*` |

### 4.3 Job flow (apply)

```text
  [Checks] ----needs----> [Plan] ----needs----> [Apply]
     |                      |                      |
     | fmt + validate       | writes tfvars        | downloads plan
     | OIDC + init          | terraform plan       | terraform apply
     |                      | uploads tfplan       | shows outputs
```

| Job | Runs when | Main steps |
|-----|-----------|------------|
| Checks | Always | checkout → setup Terraform → OIDC → init → fmt → validate |
| Plan | plan or apply | OIDC → init → write tfvars → plan → upload artifact |
| Apply | apply only | OIDC → init → write tfvars → download plan → apply |
| Destroy | destroy only | OIDC → init → write tfvars → destroy |

### 4.4 Concurrency (important)

```yaml
concurrency:
  group: vm-provision-<environment>-<cloud>
  cancel-in-progress: false
```

Meaning:

- Only **one** Terraform run at a time for the same env + cloud
- A second run **waits** (does not cancel the first)
- Example: stage/aws run #61 waits until stage/aws run #60 finishes

### 4.5 Reusable actions

| Action | Role |
|--------|------|
| `cloud-oidc` | Assume AWS role **or** login to Azure via OIDC |
| `write-tfvars` | Write `TF_VARS_AWS` or `TF_VARS_AZURE` → `terraform.tfvars` |
| `terraform-plugin-cache` | Speed up provider downloads |

---

## 5. AWS part

### 5.1 What gets created

Typically:

- EC2 instance (Amazon Linux 2023 AMI auto-selected if `ami_id` omitted)
- Uses your subnet + security group from tfvars

### 5.2 Remote state

| Item | Value (pattern) |
|------|-----------------|
| Backend type | `s3` |
| Config file | `backend/aws.hcl` |
| State key | `vm-provision/<env>/terraform.tfstate` |
| Lock table | DynamoDB (see `aws.hcl`) |

### 5.3 Authentication (OIDC)

```text
GitHub Actions
    |
    | requests OIDC token (id-token: write)
    v
AWS IAM Identity Provider (token.actions.githubusercontent.com)
    |
    | AssumeRoleWithWebIdentity
    v
IAM role (AWS_ROLE_ARN)
    |
    v
Temporary AWS credentials for Terraform
```

**Trust rule tip:** subject (`sub`) must match how GitHub issues tokens for this repo/environment (often includes numeric IDs, not only the repo name).

### 5.4 AWS run checklist

1. Environment has `AWS_ROLE_ARN`, `AWS_REGION`
2. Environment has secret `TF_VARS_AWS` with `cloud_provider = "aws"`
3. S3 bucket + DynamoDB lock table exist
4. Run workflow: `cloud = aws`

---

## 6. Azure part

### 6.1 What gets created

Typically:

- Linux VM (Amazon Linux 2023 via Azure Marketplace / Ntegral)
- NIC, optional public IP, NSG association
- Marketplace **plan** fields are required for that image

### 6.2 Remote state

| Item | Value (pattern) |
|------|-----------------|
| Backend type | `azurerm` |
| Config file | `backend/azure.hcl` |
| State key | `vm-provision/<env>/terraform.tfstate` |

### 6.3 Authentication (OIDC)

```text
GitHub Actions
    |
    | OIDC token
    v
Microsoft Entra ID (federated credential on App Registration)
    |
    v
Service Principal (AZURE_CLIENT_ID)
    |
    v
Subscription access for Terraform (ARM_* + use_oidc)
```

Federated credential subject often looks like:

```text
repo:<owner>@<id>/<repo>@<id>:environment:<env>
```

### 6.4 Azure run checklist

1. Environment has `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
2. Environment has secret `TF_VARS_AZURE` with `cloud_provider = "azure"`
3. Storage account / container for state exists
4. Marketplace image plan accepted in the subscription
5. Run workflow: `cloud = azure`

### 6.5 Note about the AWS provider on Azure runs

Both AWS and Azure providers are declared in code.  
On Azure-only runs, the workflow **stubs unused AWS credentials** so the AWS provider can configure without real AWS login. Real AWS OIDC is used only when `cloud = aws`.

---

## 7. What is common (both clouds)

| Topic | Same for AWS and Azure |
|-------|------------------------|
| Repo / module layout | Yes |
| Environments (`dev`…`prod`) | Yes |
| Workflow inputs (`action`, `environment`, `cloud`) | Yes |
| Mandatory tags | `Team`, `Application`, `CostCentre` |
| Terraform version | `1.9.0` in workflows |
| Init helper | `scripts/init-backend.sh` |
| Concurrency lock | per env + cloud |
| Plan artifact on apply | Yes |
| Secrets model | separate tfvars secret per cloud |

| Topic | Different |
|-------|-----------|
| Login | AWS IAM OIDC vs Azure federated credential |
| State backend | S3+DynamoDB vs Azure Storage |
| Compute API | EC2 vs Azure VM |
| Network IDs | `subnet-…` / `sg-…` vs full Azure resource IDs |
| Image | AWS AMI lookup vs Marketplace image + plan |

### Shared Terraform idea

```text
cloud_provider = "aws" | "azure"
        |
        v
   module "vm"
        |
   +----+----+
   |         |
 aws[]     azure[]
 (count)   (count)
```

Only one cloud submodule is created (`count = 1` or `0`).

---

## 8. End-to-end flows

### 8.1 Apply on AWS (example: dev)

```text
1. Human: Run workflow
     action=apply, environment=dev, cloud=aws
2. Checks job
     OIDC -> AWS role
     init-backend.sh aws  -> S3 state
     fmt + validate
3. Plan job
     write TF_VARS_AWS -> terraform.tfvars
     terraform plan -out=tfplan
     upload artifact
4. Apply job
     download tfplan
     terraform apply tfplan
5. Result: EC2 (and related) created/updated
```

### 8.2 Apply on Azure (example: dev)

```text
1. Human: Run workflow
     action=apply, environment=dev, cloud=azure
2. Checks job
     OIDC -> Azure SP
     stub unused AWS creds
     init-backend.sh azure -> Azure state
     fmt + validate
3. Plan / Apply
     write TF_VARS_AZURE -> terraform.tfvars
     plan then apply
4. Result: Azure VM (and related) created/updated
```

### 8.3 Pull request

```text
PR opened/updated
   -> pr-validation.yml
      for each env (dev, stage, uat, prod):
        init (no backend)
        fmt
        validate
        check tags in both *.example files
```

No cloud credentials needed for PR checks (backend disabled).

---

## 9. Step-by-step: run a deploy

### First-time setup (once per Environment)

1. Create GitHub Environment: `dev` (repeat for stage/uat/prod).
2. Add variables: AWS + Azure IDs as needed.
3. Paste AWS tfvars into secret `TF_VARS_AWS`.
4. Paste Azure tfvars into secret `TF_VARS_AZURE`.
5. Confirm cloud IAM trust / federated credentials allow this repo + environment.

### Every deploy

1. Open repo → **Actions** → **Terraform**.
2. Click **Run workflow**.
3. Choose:
   - **action**: `plan` first (recommended), then `apply`
   - **environment**: e.g. `dev`
   - **cloud**: `aws` or `azure`
4. Watch jobs: Checks → Plan → Apply.
5. Read outputs in the Apply job summary.

### Destroy

Same as deploy, but `action = destroy`.  
Use carefully: destroys resources tracked in that env+cloud state.

---

## 10. Step-by-step: switch cloud

You do **not** edit code to switch clouds.

| Goal | What to do |
|------|------------|
| Deploy AWS | Run workflow with `cloud=aws` |
| Deploy Azure | Run workflow with `cloud=azure` |
| Update AWS settings | Edit Environment secret `TF_VARS_AWS` |
| Update Azure settings | Edit Environment secret `TF_VARS_AZURE` |

Local testing:

```bash
cd terraform/environments/dev

# AWS
../../scripts/init-backend.sh aws
terraform plan -var-file=terraform_aws.tfvars

# Azure
../../scripts/init-backend.sh azure
terraform plan -var-file=terraform.tfvars
```

---

## 11. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Azure resources created on AWS run | Wrong secret / `cloud_provider` still azure | Ensure `TF_VARS_AWS` has `cloud_provider = "aws"` |
| `No valid credential sources` (AWS provider) on Azure run | Old workflow without AWS stub | Use latest `main` (cloud-oidc stubs AWS on Azure) |
| `AssumeRoleWithWebIdentity` denied | IAM trust `sub` mismatch | Align trust with GitHub subject format |
| State lock / waiting forever | Another run for same env+cloud | Wait for it, or cancel the older run if safe |
| Resource already exists (import) | Resource in cloud but not in this state | Import, or destroy orphan, or use correct backend |
| DynamoDB / S3 not found | Backend resources missing | Create bucket + lock table from `backend/aws.hcl` |
| Marketplace purchase errors | Plan/image not accepted | Accept marketplace terms for AL2023 image |

---

## 12. Glossary

| Term | Meaning |
|------|---------|
| **OIDC** | Short-lived login from GitHub to cloud (no stored cloud password) |
| **tfvars** | Variable values for Terraform (network IDs, sizes, tags) |
| **Remote state** | Shared Terraform state file in S3 or Azure Storage |
| **Backend** | Where state is stored/locked |
| **Plan** | Preview of changes |
| **Apply** | Execute the plan |
| **Destroy** | Remove managed resources |
| **Drift** | Real cloud config differs from Terraform state/code |
| **Environment (GitHub)** | Scoped vars/secrets/protection for `dev`/`stage`/`uat`/`prod` |
| **Concurrency group** | Queue so two deploys don’t fight the same state |

---

## Quick reference card

```text
Deploy AWS  = Actions > Terraform > apply + env + cloud=aws
Deploy Azure= Actions > Terraform > apply + env + cloud=azure

Secrets     = TF_VARS_AWS and TF_VARS_AZURE (both kept)
State AWS   = S3 + DynamoDB (backend/aws.hcl)
State Azure = Storage account (backend/azure.hcl)
Auth        = OIDC (no long-lived cloud keys in GitHub)
```

---

*Document version: aligned with tag `final` / current `main` multi-cloud layout.*
