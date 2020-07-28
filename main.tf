variable "cmd" {
  description = "The command used to create the resource."
}

variable "destroy_cmd" {
  description = "The command used to destroy the resource."
}

variable "account_id" {
  description = "The account that holds the role to assume in. Will use providers account by default"
  default     = "0"
}

variable "role" {
  description = "The role to assume in order to run the cli command."
  default     = "0"
}

variable "dependency_ids" {
  description = "IDs or ARNs of any resources that are a dependency of the resource created by this module."
  type        = "list"
  default     = []
}

data "aws_caller_identity" "id" {}

locals {
  account_id      = "${var.account_id == 0 ? data.aws_caller_identity.id.account_id : var.account_id}"
  assume_role_cmd = "source ${path.module}/assume_role.sh ${local.account_id} ${var.role}"
}

resource "null_resource" "cli_resource" {
  provisioner "local-exec" {
    when    = "create"
    command = "/bin/bash -c '${var.role == 0 ? "" : "${local.assume_role_cmd} && "}${var.cmd}'"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "/bin/bash -c '${var.role == 0 ? "" : "${local.assume_role_cmd} && "}${var.destroy_cmd}'"
  }

  # By depending on the null_resource, the cli resource effectively depends on the existance
  # of the resources identified by the ids provided via the dependency_ids list variable.
  depends_on = ["null_resource.dependencies"]
}

resource "null_resource" "dependencies" {
  triggers = {
    dependencies = "${join(",", var.dependency_ids)}"
  }
}

output "id" {
  description = "The ID of the null_resource used to provison the resource via cli. Useful for creating dependencies between cli resources"
  value       = "${null_resource.cli_resource.id}"
}
