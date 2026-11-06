# Lab 5

## Why for_each here and count there
Subnets use 'for_each' because each subnet has a stable key name, so adding or removing one never affects the others. Using 'count' for subnets is dangerous because removing an item shifts index positions, causing Terraform to destroy and recreate unrelated subnets. The S3 bucket uses 'count' because it relies on a simple toggle to create zero or one resource. In short, use 'count' when asking how many resources to create, and 'for_each' when tracking which specific resources to manage.
