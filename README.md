# terraform-aws-iam-role

Terraform module for a generic assumable IAM role: an assume-role policy
for a single principal, plus optional managed policy attachments and an
optional inline policy.

## Cost

IAM roles, policies, and policy attachments carry no charge. This
module has no cost impact of its own.

## Design

`permissions_boundary` caps what the role can ever do, no matter what
`managed_policy_arns` or `inline_policy` later grant it — a real guard
against privilege escalation worth setting whenever this module hands
a role's definition to another team, a CI pipeline, or any other
automation that is not fully trusted with unrestricted IAM.

### Attaching a policy this configuration creates

`managed_policy_arns` takes AWS-managed ARNs and equally the `arn` output
of a customer managed policy from
[`terraform-aws-iam-policy`](https://github.com/kn47ytv9mv/terraform-aws-iam-policy).
That second case is why the attachments are addressed by **position in the
list** rather than by the ARN itself: a policy created in the same apply
has no ARN at plan time, and keying resource instances on an unknown value
fails the plan outright with *"the for_each set includes values derived
from resource attributes that cannot be determined until apply."* A list's
length is known even when none of its elements are, so indexing plans
cleanly either way.

The consequence worth knowing: **appending to the list is safe, but
reordering or removing an entry moves every later attachment**, and
Terraform will replace the ones that shifted. Detaching and reattaching a
managed policy is brief but not free of effect, so append rather than
insert.

## Usage

```hcl
module "role" {
  source = "kn47ytv9mv/iam-role/aws"

  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  managed_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}
```

Or directly from this repository:

```hcl
module "role" {
  source = "github.com/kn47ytv9mv/terraform-aws-iam-role"

  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  managed_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.0 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | The name of the IAM role. If null, a unique name is generated. | `null` | no |
| principal_type | Type of principal allowed to assume this role (e.g. `'Service'`, `'AWS'`). | `"Service"` | no |
| principal_identifiers | Identifiers of the principal(s) allowed to assume this role (e.g. `['ecs-tasks.amazonaws.com']`). | `null` | no |
| assume_role_actions | Actions allowed in the assume-role policy statement. | `["sts:AssumeRole"]` | no |
| managed_policy_arns | ARNs of managed policies to attach to the role. | `[]` | no |
| inline_policy | JSON policy document to attach to the role as an inline policy. If null, no inline policy is attached. | `null` | no |
| permissions_boundary | ARN of a managed policy to use as the role's permissions boundary — caps what the role can ever do, regardless of what managed_policy_arns or inline_policy grant it, a real guard against privilege escalation for a role this module hands to another team or automated process to define. If null, the role has no permissions boundary. | `null` | no |
| tags | A map of tags to assign to the role. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID (name) of the role. |
| arn | The ARN of the role. |
| name | The name of the role. |

## License

MIT — see [LICENSE.md](LICENSE.md).
