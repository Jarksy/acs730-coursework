# Lab 5

## What I Built
Dual-Target Terraform Setup: Works seamlessly with both real AWS and LocalStack.
VPC and Subnets: Custom VPC with public subnets created dynamically using 'for_each'.
Networking and Security: Internet Gateway, public Route Table, and a Web Security Group.
Compute: EC2 web server automatically installing 'nginx'.
Storage: Optional S3 artifact bucket managed with a 'count' toggle.

## Why for_each here and count there
Subnets use 'for_each' because each subnet has a stable key name, so adding or removing one never affects the others. Using 'count' for subnets is dangerous because removing an item shifts index positions, causing Terraform to destroy and recreate unrelated subnets. The S3 bucket uses 'count' because it relies on a simple toggle to create zero or one resource. In short, use 'count' when asking how many resources to create, and 'for_each' when tracking which specific resources to manage.

## Why not plan and apply against real AWS on every pull request
Cost: Running real AWS resources on every PR drains fixed lab budgets fast. LocalStack is free.
Security: Storing permanent AWS keys in GitHub secrets creates security and leakage risks.
Session Expiration: AWS Academy lab tokens expire every few hours, causing valid PRs to fail.
Speed: Real deployments are slow and suffer from rate limits and naming collisions.
Testing Limits: LocalStack quickly verifies code structure and syntax without risking live infrastructure.

## Experiments
### Experiment 2: Remove depends_on
Prediction: I predicted that commenting out 'depends_on' would alter the resource list in 'terraform plan'.
Actual Result: The plan output remained completely identical because 'depends_on' only affects deployment ordering during 'apply', not the plan creation itself.

### Experiment 4: Turn Off the S3 Bucket
Prediction: I predicted that setting 'create_artifact_bucket = false' would cause 'terraform output' to fail with an index error.
Actual Result: The output printed 'null' instead, demonstrating that the 'one()' function safely handles empty lists without crashing.
