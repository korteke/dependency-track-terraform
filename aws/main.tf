locals {
  dt_db_engine_version = var.db_engine_version
  dt_db_port           = 5432
  dt_db_instance_size  = var.db_instance_size
  dt_db_name           = var.db_name
  db_creds             = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

#------------------------------------------------------------------------------
# AWS Cloudwatch Logs
#------------------------------------------------------------------------------
module "aws_cw_logs" {
  source  = "cn-terraform/cloudwatch-logs/aws"
  version = "1.0.12"

  create_kms_key              = var.create_kms_key
  log_group_kms_key_id        = var.log_group_kms_key_id
  log_group_retention_in_days = var.log_group_retention_in_days
  logs_path                   = "/ecs/service/${var.name_prefix}-dt"

  tags = var.tags
}

#------------------------------------------------------------------------------
# ECS Fargate Service
#------------------------------------------------------------------------------
module "ecs_fargate" {
  source  = "cn-terraform/ecs-fargate/aws"
  version = "2.0.51"

  name_prefix                  = "${var.name_prefix}-dt"
  vpc_id                       = var.vpc_id
  public_subnets_ids           = var.public_subnets_ids
  private_subnets_ids          = var.private_subnets_ids
  container_name               = "${var.name_prefix}-dt"
  container_image              = var.dt_api_image
  container_cpu                = var.api_container_cpu
  container_memory             = var.api_container_memory
  container_memory_reservation = var.api_container_memory_reservation
  enable_autoscaling           = var.enable_autoscaling
  ephemeral_storage_size       = var.ephemeral_storage_size
  volumes                      = var.volumes
  mount_points                 = var.mount_points
  permissions_boundary         = var.permissions_boundary

  # Deployment circuit breaker
  deployment_circuit_breaker_enabled  = var.deployment_circuit_breaker_enabled
  deployment_circuit_breaker_rollback = var.deployment_circuit_breaker_rollback

  # Application Load Balancer
  custom_lb_arn                       = var.custom_lb_arn
  lb_http_ports                       = var.lb_http_ports
  lb_https_ports                      = var.lb_https_ports
  lb_enable_cross_zone_load_balancing = var.lb_enable_cross_zone_load_balancing
  lb_waf_web_acl_arn                  = var.lb_waf_web_acl_arn
  default_certificate_arn             = var.enable_ssl ? module.acm[0].acm_certificate_arn : null

  # Application Load Balancer Logs
  enable_s3_logs                                 = var.enable_s3_logs
  block_s3_bucket_public_access                  = var.block_s3_bucket_public_access
  enable_s3_bucket_server_side_encryption        = var.enable_s3_bucket_server_side_encryption
  s3_bucket_server_side_encryption_sse_algorithm = var.s3_bucket_server_side_encryption_sse_algorithm
  s3_bucket_server_side_encryption_key           = var.s3_bucket_server_side_encryption_key

  command = [
    ""
  ]
  ulimits = [
    {
      "name" : "nofile",
      "softLimit" : 65535,
      "hardLimit" : 65535
    }
  ]
  port_mappings = [
    {
      containerPort = 9000
      hostPort      = 9000
      protocol      = "tcp"
    }
  ]
  environment = [
    {
      name = "ALPINE_DATABASE_MODE"
      value = "external"
    }
    ,
    {
      name = "ALPINE_DATABASE_URL"
      value = "jdbc:postgresql://${aws_rds_cluster.aurora_db.endpoint}/${local.dt_db_name}?sslmode=require"
    }
    ,
    {
      name  = "ALPINE_DATABASE_DRIVER"
      value = "org.postgresql.Driver"
    }
    ,
    {
      name  = "ALPINE_DATABASE_USERNAME"
      value = local.db_creds.username
    },
    {
      name  = "ALPINE_DATABASE_PASSWORD"
      value = local.db_creds.password
    }
    ,
    {
      name  = "ALPINE_DATABASE_POOL_ENABLED"
      value = "true"
    }
    ,
    {
      name = "API_BASE_URL"
      value = "https://localhost:8081"
    }
    ,
    {
      name = "EXTRA_JAVA_OPTIONS"
      value = ""
    }
    ,
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.region
      "awslogs-group"         = "/ecs/service/${var.name_prefix}-dt"
      "awslogs-stream-prefix" = "ecs"
    }
    secretOptions = null
  }

  tags = var.tags
}