output "secret_arn" {
  value = aws_ssm_parameter.db.name
}

output "secret_name" {
  value = aws_ssm_parameter.db.name
}
