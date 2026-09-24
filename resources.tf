resource "random_uuid" "resource" {}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = var.assume_role_actions

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifiers
    }
  }
}

resource "aws_iam_role" "resource" {
  name                 = coalesce(var.name, random_uuid.resource.id)
  assume_role_policy   = data.aws_iam_policy_document.assume.json
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "resource" {
  count = length(var.managed_policy_arns)

  role       = aws_iam_role.resource.name
  policy_arn = var.managed_policy_arns[count.index]
}

resource "aws_iam_role_policy" "resource" {
  for_each = { for policy in var.inline_policy[*] : "inline" => policy }

  name   = "${aws_iam_role.resource.name}-inline"
  role   = aws_iam_role.resource.id
  policy = each.value
}

output "id" {
  description = "The ID (name) of the role."
  value       = aws_iam_role.resource.id
}

output "arn" {
  description = "The ARN of the role."
  value       = aws_iam_role.resource.arn
}

output "name" {
  description = "The name of the role."
  value       = aws_iam_role.resource.name
}
