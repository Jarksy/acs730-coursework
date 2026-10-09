Production AWS accounts use OIDC so build servers get temporary permissions on the spot, avoiding stored passwords that need constant updating.

This course uses temporary session credentials because AWS Academy blocks setting up OIDC, but security risks stay low since those keys stop working when your lab time runs out.

## Experiments

### Experiment 1: Let Credentials Expire
Prediction: The `Configure AWS credentials` or `terraform plan` step will fail with an expired token error because AWS temporary security credentials timed out.

Result: The `terraform plan` step failed with `Error: ExpiredToken: The security token included in the request is expired`. After starting a new AWS session and running `./scripts/refresh-gha-creds.sh`, the workflow re-ran successfully without requiring any code or file changes in the repository.

### Experiment 2: Remove the S3 Backend
Prediction: If we remove the S3 backend from Terraform, GitHub Actions won't know where our existing infrastructure is saved and will try to build everything again from scratch.

Result: Terraform creates a local `terraform.tfstate` file on your machine instead of using S3. Because GitHub Actions runs on a temporary cloud runner that doesn't have this local file, it loses track of existing AWS resources and attempts to re-create them.
