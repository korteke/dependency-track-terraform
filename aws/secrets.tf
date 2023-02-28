resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "_%@"
}
 
resource "aws_secretsmanager_secret" "dt-database-secret" {
   name = "dt-database-secret"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.dt-database-secret.id
  secret_string = <<EOF
   {
    "username": "${var.db_username}",
    "password": "${random_password.password.result}"
   }
EOF
}

data "aws_secretsmanager_secret" "dt-database-secret" {
  arn = aws_secretsmanager_secret.dt-database-secret.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.dt-database-secret.arn
}