# assignment-db-credentials: single source of truth for the app's DB connection
# info. EC2 instances read this at boot instead of having credentials baked into
# an AMI or passed in plaintext user-data.
#
# In AWS Academy Learner Lab, the pre-provisioned LabRole already exists, but
# the lab account typically does not permit attaching new managed policies.
# Grant the app's existing role explicit Secrets Manager read access instead.
resource "aws_iam_role_policy" "db_secret_read" {
  name = "assignment-db-secret-read"
  role = "LabRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RetrieveDbSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "db" {
  name                    = var.secret_name
  description             = "RDS connection details for the event-ticketing app (${var.name_prefix} sandbox)"
  recovery_window_in_days = 0 # skip 30-day soft-delete; allows immediate re-creation

  tags = {
    Name = var.secret_name
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
    username = var.db_username
    password = var.db_password
  })
}

