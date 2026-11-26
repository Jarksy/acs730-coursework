# Assignment 1 Report: Multi-Environment Terraform & CI/CD Delivery

## 1. Introduction
This report walks through the setup built for ACS730 Assignment 1 under `assignment1/`, covering the Terraform infrastructure, GitHub Actions pipeline, credential handling, secret lookup, CloudWatch alarm, and cleanup steps. Instead of copying infrastructure code for each environment, a reusable module (`assignment1/terraform/modules/app_stack`) creates separate networking, Session Manager compute, and monitoring resources for `dev`, `staging`, and `prod`, storing each environment's state under its own S3 key. A root GitHub Actions workflow watching `assignment1/**` deploys `staging` automatically when changes merge into main, while requiring manual approval before deploying to `prod`.

## 2. Module, State Setup, and SSM Pre-Step
- **Reusable Module and S3 State:** Instead of duplicating the same resources for every environment, `modules/app_stack` takes variables like `env`, `aws_region`, `vpc_cidr`, `subnets`, `instance_type`, `ssm_parameter_name`, `alarm_cpu_threshold`, and `tags`, while sharing common tags and naming in `locals`. Each environment uses its own S3 state key, (`assignment1/staging/terraform.tfstate`, `assignment1/prod/terraform.tfstate` and `assignment1/dev/terraform.tfstate`). Repeated resources such as subnets use `for_each` rather than `count` so adding or changing entries does not shift list indexes and cause unintended resource replacements.
- **Security & Alarm Metric:** Instance access uses AWS Systems Manager (Session Manager) with no SSH keys stored in the repository and no port `22` open to `0.0.0.0/0`, while the CloudWatch alarm tracks an active metric (such as CPU utilization) that emits datapoints even on an idle instance so it moves past `INSUFFICIENT_DATA`.
- **Out-of-Band SSM Pre-Step:** The SSM parameter was created once out-of-band before Terraform ran and read via `data "aws_ssm_parameter"` (with no `aws_ssm_parameter` resource in Terraform):
```bash
  aws ssm put-parameter \
    --name "/assignment1/app/db_password" \
    --value "Assignment1-Placeholder" \
    --type "SecureString" \
    --overwrite
```
- **Per-Session Credential Refresh:** After moving credentials from repository scope to environment scope, credentials were refreshed using the three-argument command:
```bash
./scripts/refresh-gha-creds.sh Jarksy/acs730-coursework staging prod
```

## 3. Scoped Credentials and OIDC Trust Policy
In a real AWS account (outside the AWS Learner Lab, where IAM write permissions are denied, which is why this policy is documented rather than deployed), GitHub Actions can authenticate via OIDC instead of long-lived or session-refreshed access keys:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:Jarksy/acs730-coursework:environment:prod"
        }
      }
    }
  ]
}
```
**Condition-by-Condition Analysis**
- `token.actions.githubusercontent.com:aud` = `sts.amazonaws.com`: Prevents tokens minted for other audiences or external services from being accepted by AWS STS as a credential exchange token for AWS.
- `token.actions.githubusercontent.com:sub` = `"repo:Jarksy/acs730-coursework:environment:prod"`: Pins role assumption strictly to workflows in `Jarksy/acs730-coursework` running inside the `prod` GitHub Environment (which itself is restricted to `main` and guarded by a manual reviewer). Under a broad repo-wide wildcard (`repo:Jarksy/acs730-coursework:*`), someone with push access to another branch could modify a workflow on that branch, run a job, and assume the role if not blocked by environment/branch constraints; scoping `sub` to `repo:Jarksy/acs730-coursework:environment:prod` restricts assumption to workflows running in the protected `prod` environment on `main`.

## 4. Pipeline Recommendation: GitHub Actions vs. AWS-Native Pipeline
For a team committed to AWS with no multi-cloud plans, I recommend an AWS-native pipeline (CodePipeline + CodeBuild / IAM Roles Anywhere or native OIDC/service roles) over GitHub Actions for production infrastructure delivery, based on three concrete factors:
1. **Identity & Credential Locality:** With an AWS-native pipeline, execution roles and resource policies live directly inside IAM and VPC boundaries without external OIDC token exchange or external secret rotation, reducing cross-platform trust surface area.
2. **Runner Cost, Patching, and Lifecycle Ownership:** GitHub-hosted runners run on external infrastructure outside your AWS billing and patch-management model, whereas AWS-native build/deploy stages integrate directly with AWS service quotas, CloudTrail auditing, and account-level governance.
3. **Private / VPC-Internal Access:** When target resources sit inside private subnets or behind VPC endpoints without public ingress, an AWS-native runner/deployment path inside or peered to the VPC reaches internal endpoints cleanly without exposing deployment paths over the public internet or standing up self-hosted runner management overhead.

## 5. Conclusion
Using a shared Terraform module with separate state files, limiting `prod` deployments to `main` with manual approval, keeping secrets scoped to each environment, and pairing a pre-created SSM parameter with a metric-backed CloudWatch alarm makes the deployment process consistent and easy to track. Just as important, saving evidence at the right time and deleting running resources once I am done protects my $50 budget. Watching out for small mistakes, like sharing a state key across environments, updating the wrong credential scope, or forgetting to save CI/CD and alarm evidence before teardown, helps to avoid wasted debugging time and extra costs.
