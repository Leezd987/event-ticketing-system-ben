# assignment-db-credentials: single source of truth for the app's DB connection
# info. EC2 instances read this at boot instead of having credentials baked into
# an AMI or passed in plaintext user-data.
#
# In AWS Academy Learner Lab, the pre-provisioned LabRole already has the SSM
# permissions needed to read SecureString parameters, so store the DB config in
# SSM Parameter Store instead of creating or modifying IAM role policies.
resource "aws_ssm_parameter" "db" {
  name        = var.secret_name
  description = "RDS connection details for the event-ticketing app (${var.name_prefix} sandbox)"
  type        = "SecureString"
  value = jsonencode({
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
    username = var.db_username
    password = var.db_password
  })
  overwrite = true
}

