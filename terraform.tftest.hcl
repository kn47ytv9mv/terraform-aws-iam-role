mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "name_defaults_to_random_uuid" {
  command = apply

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
  }

  assert {
    condition     = aws_iam_role.resource.name == random_uuid.resource.id
    error_message = "Leaving name unset should fall back to the generated random_uuid."
  }
}

run "explicit_name_overrides_random_uuid" {
  command = plan

  variables {
    name                  = "my-custom-role"
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
  }

  assert {
    condition     = aws_iam_role.resource.name == "my-custom-role"
    error_message = "An explicit name should override the random_uuid fallback."
  }
}

run "managed_policy_arns_creates_attachments" {
  command = plan

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    ]
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.resource) == 2
    error_message = "Two managed_policy_arns entries should create two attachment resources."
  }
}

run "no_inline_policy_by_default" {
  command = plan

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
  }

  assert {
    condition     = length(aws_iam_role_policy.resource) == 0
    error_message = "Leaving inline_policy unset should create no inline policy resource."
  }
}

run "inline_policy_creates_one_named_policy" {
  command = apply

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
    inline_policy         = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition     = length(aws_iam_role_policy.resource) == 1
    error_message = "Setting inline_policy should create exactly one inline policy resource."
  }

  assert {
    condition     = aws_iam_role_policy.resource["inline"].name == "${aws_iam_role.resource.name}-inline"
    error_message = "The inline policy's name should be derived from the role's own name."
  }
}

run "permissions_boundary_passes_through" {
  command = plan

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
    permissions_boundary  = "arn:aws:iam::123456789012:policy/DeveloperBoundary"
  }

  assert {
    condition     = aws_iam_role.resource.permissions_boundary == "arn:aws:iam::123456789012:policy/DeveloperBoundary"
    error_message = "permissions_boundary should pass through unchanged."
  }
}

run "no_permissions_boundary_by_default" {
  command = plan

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
  }

  assert {
    condition     = aws_iam_role.resource.permissions_boundary == null
    error_message = "Leaving permissions_boundary unset should leave the role with no permissions boundary."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    principal_identifiers = ["ecs-tasks.amazonaws.com"]
    managed_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  }
}

run "attachments_are_addressed_by_position_not_by_arn" {
  command = plan

  variables {
    principal_identifiers = ["ec2.amazonaws.com"]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
    ]
  }

  assert {
    condition     = aws_iam_role_policy_attachment.resource[0].policy_arn == "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    error_message = "Attachments must be indexed by position. Keying them on the ARN itself makes the plan fail whenever a policy is created in the same apply, because the ARN is not known yet."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.resource[1].policy_arn == "arn:aws:iam::aws:policy/ReadOnlyAccess"
    error_message = "The second attachment should take the second ARN in the list."
  }
}
