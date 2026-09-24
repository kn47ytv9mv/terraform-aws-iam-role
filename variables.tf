variable "name" {
  default     = null
  description = "The name of the IAM role. If null, a unique name is generated."
}

variable "principal_type" {
  default     = "Service"
  description = "Type of principal allowed to assume this role (e.g. 'Service', 'AWS')."
}

variable "principal_identifiers" {
  default     = null
  description = "Identifiers of the principal(s) allowed to assume this role (e.g. ['ecs-tasks.amazonaws.com'])."
}

variable "assume_role_actions" {
  default     = ["sts:AssumeRole"]
  description = "Actions allowed in the assume-role policy statement."
}

variable "managed_policy_arns" {
  default     = []
  description = "ARNs of managed policies to attach to the role — AWS-managed ARNs, or a customer managed policy's arn output from terraform-aws-iam-policy. Attachments are addressed by position in this list, so appending is safe and reordering replaces the attachments that moved."
}

variable "inline_policy" {
  default     = null
  description = "JSON policy document to attach to the role as an inline policy. If null, no inline policy is attached."
}

variable "permissions_boundary" {
  default     = null
  description = "ARN of a managed policy to use as the role's permissions boundary — caps what the role can ever do, regardless of what managed_policy_arns or inline_policy grant it, a real guard against privilege escalation for a role this module hands to another team or automated process to define. If null, the role has no permissions boundary."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the role."
}
