output "aws_caller_identity" {
  description = "AWS caller identity."
  value = data.aws_caller_identity.current.account_id
}