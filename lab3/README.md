# Lab 3

Production AWS accounts use OIDC so build servers get temporary permissions on the spot, avoiding stored passwords that need constant updating.

This course uses temporary session credentials because AWS Academy blocks setting up OIDC, but security risks stay low since those keys stop working when your lab time runs out.

## Experiments

### Experiment 1: Let Credentials Expire
Prediction: The `Configure AWS credentials` or `terraform plan` step will fail with an expired token error because AWS temporary security credentials timed out.
Result: The `terraform plan` step failed with `Error: ExpiredToken: The security token included in the request is expired`. After starting a new AWS session and running `./scripts/refresh-gha-creds.sh`, the workflow re-ran successfully without requiring any code or file changes in the repository.

### Experiment 2: Remove AWS_REGION Variable
Prediction: Removing `AWS_REGION` from GitHub repository variables will cause `terraform init` to crash with a critical authentication failure because Terraform cannot locate AWS.
Result: The workflow did not crash on authentication, but instead failed early during the `Configure AWS credentials` action with the error `Input required and not supplied: aws-region`. The region is a required runner configuration parameter rather than a direct Terraform provider error.
