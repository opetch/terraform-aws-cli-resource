AWS CLI Resource Terraform Module
=================================

This module is used to create a AWS resource in terraform by calling out to the CLI, with support for cross account resource creation (see example). The module encapsulates the act of assuming a role, when required to create the resource in the specified account. 

Use Cases
--------
 * Situations where it's not possible to create resources in the desired configuration due to cross account permissions. (see example)
 * When terraform does not yet have support for a resource and resorting to CLI is a necessary compromise 

Prerequisites
-------------
 * Must be using sts assume role as a means to authenticate.
 * The credentials terraform is using to run must resolve to a identity with permissions allowing assuming of the roles the module is configured to use.

Example Usage
-------------
This module was created initially to combat the issue with the aws provider for terraform where it is not possible to associate a route53 zone to a VPC in a different account [Issue 617 (aws-provider)](https://github.com/terraform-providers/terraform-provider-aws/issues/617) and [Issue 12465](https://github.com/hashicorp/terraform/issues/12465) for more details.

Use of the CLI circumvents the bug mentioned above and the inclusion of the sts assume role support elieveates some of the pain caused by [Issue 3 (null provider)](https://github.com/terraform-providers/terraform-provider-null/issues/3)

```hcl
locals {
  cli_flags = "--hosted-zone-id SOME_HOSTEDZONEID --vpc VPCRegion=eu-west-1,VPCId=vpc-abc123xyz"
}

module "create_vpc_association_authorization" {
  source = "../../cli_resource"

  account_id      = "123456789" # Account with the private hosted zone
  role            = "TF_Role"
  cmd             = "aws route53 create-vpc-association-authorization ${local.cli_flags}"
  destroy_cmd     = "aws route53 delete-vpc-association-authorization ${local.cli_flags}"
}

module "associate_vpc_with_zone" {
  source = "../../cli_resource"

  # Uses the default provider account id if no account id is passed in
  role            = "TF_Role"
  cmd             = "aws route53 associate-vpc-with-hosted-zone ${local.cli_flags}"
  destroy_cmd     = "aws route53 disassociate-vpc-from-hosted-zone ${local.cli_flags}"

  # Require that the above resource is created first 
  dependency_ids  = ["${module.create_vpc_association_authorization.id}"] 
}
```

Terraform version
-----------------
Terraform version 0.11.3 has been used when creating the module, however many previous versions should work also but have not been tested.
