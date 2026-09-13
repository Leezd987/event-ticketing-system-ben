# assignment-db-credentials: single source of truth for the app's DB connection
# info. EC2 instances read this at boot instead of having credentials baked into
# an AMI or passed in plaintext user-data.
#
# In AWS Academy Learner Lab, the pre-provisioned `LabInstanceProfile`
# commonly does not include the AWS managed SSM policy needed for EC2 agents to
# register with SSM. Reuse the existing role and attach the managed policy
# instead of creating a new role or custom permissions model.
data "aws_iam_instance_profile" "lab" {
  name = var.instance_profile_name
}

locals {
  lab_role_name = data.aws_iam_instance_profile.lab.roles[0]
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = local.lab_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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

