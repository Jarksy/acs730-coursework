output "vpc_id" {
  description = "ID of the provisioned VPC."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Map of subnet keys to subnet IDs."
  value       = { for k, s in aws_subnet.this : k => s.id }
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.app.id
}

output "cloudwatch_alarm_name" {
  description = "Name of the CloudWatch CPU alarm."
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "ssm_parameter_name_read" {
  description = "SSM parameter path read by the data source."
  value       = data.aws_ssm_parameter.app_config.name
}
