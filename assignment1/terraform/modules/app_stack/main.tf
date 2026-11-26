locals {
  name_prefix = "acs730-a1-${var.env}"
  common_tags = merge(
    {
      Project     = "acs730-assignment1"
      Environment = var.env
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_ssm_parameter" "app_config" {
  name            = var.ssm_parameter_name
  with_decryption = true
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = "${var.aws_region}${each.value.az_suffix}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow outbound traffic; no public SSH ingress on port 22."
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
  })
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = values(aws_subnet.this)[0].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = "LabInstanceProfile"

  user_data = base64encode(<<-USERDATA
              #!/bin/bash
              echo "APP_ENV=${var.env}" > /etc/acs730-app.env
              echo "APP_SECRET_LEN=${length(data.aws_ssm_parameter.app_config.value)}" >> /etc/acs730-app.env
              USERDATA
  )

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${local.name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.alarm_cpu_threshold

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-high-cpu"
  })
}
