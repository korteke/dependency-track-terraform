#------------------------------------------------------------------------------
# Dependency Track ALB DNS
#------------------------------------------------------------------------------
output "dt_lb_id" {
  description = "Dependency Track Load Balancer ID"
  value       = module.ecs_fargate.aws_lb_lb_id
}

output "dt_lb_arn" {
  description = "Dependency Track Load Balancer ARN"
  value       = module.ecs_fargate.aws_lb_lb_arn
}

output "dt_lb_arn_suffix" {
  description = "Dependency Track Load Balancer ARN Suffix"
  value       = module.ecs_fargate.aws_lb_lb_arn_suffix
}

output "dt_lb_dns_name" {
  description = "Dependency Track Load Balancer DNS Name"
  value       = module.ecs_fargate.aws_lb_lb_dns_name
}

output "dt_lb_zone_id" {
  description = "Dependency Track Load Balancer Zone ID"
  value       = module.ecs_fargate.aws_lb_lb_zone_id
}

#------------------------------------------------------------------------------
# AWS SECURITY GROUPS
#------------------------------------------------------------------------------
output "ecs_tasks_sg_id" {
  description = "Dependency Track ECS Tasks Security Group - The ID of the security group"
  value       = module.ecs_fargate.ecs_tasks_sg_id
}