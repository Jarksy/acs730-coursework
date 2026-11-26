output "vpc_id" {
  value = module.app_stack.vpc_id
}

output "subnet_ids" {
  value = module.app_stack.subnet_ids
}

output "instance_id" {
  value = module.app_stack.instance_id
}

output "cloudwatch_alarm_name" {
  value = module.app_stack.cloudwatch_alarm_name
}
