variable "cmd" {
  type        = string
  description = "The command used to create the resource."
}

variable "destroy_cmd" {
  type        = string
  description = "The command used to destroy the resource."
  default     = "true"
}

variable "account_id" {
  type        = string
  description = "The account that holds the role to assume in. Will use providers account by default"
  default     = ""
}

variable "role" {
  type        = string
  description = "The role to assume in order to run the cli command."
  default     = ""
}

variable "dependency_ids" {
  description = "IDs or ARNs of any resources that are a dependency of the resource created by this module."
  type        = list(string)
  default     = []
}

data "aws_caller_identity" "id" {}

locals {
  account_id      = var.account_id == "" ? data.aws_caller_identity.id.account_id : var.account_id
  assume_role_cmd = "source ${path.module}/assume_role.sh ${local.account_id} ${var.role}"
}

resource "null_resource" "cli_resource" {
  triggers = {
    role            = var.role
    cmd             = var.cmd
    destroy_cmd     = var.destroy_cmd
    assume_role_cmd = local.assume_role_cmd
  }
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash -c '${self.triggers.role == "" ? "" : "${self.triggers.assume_role_cmd} && "}${self.triggers.cmd == "" ? "true" : self.triggers.cmd}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "/bin/bash -c '${self.triggers.role == "" ? "" : "${self.triggers.assume_role_cmd} && "}${self.triggers.destroy_cmd == "" ? "true" : self.triggers.destroy_cmd}'"
  }

  # By depending on the null_resource, the cli resource effectively depends on the existance
  # of the resources identified by the ids provided via the dependency_ids list variable.
  depends_on = [
    null_resource.dependencies
  ]
}

resource "null_resource" "dependencies" {
  triggers = {
    dependencies = join(",", var.dependency_ids)
  }
}

output "id" {
  description = "The ID of the null_resource used to provison the resource via cli. Useful for creating dependencies between cli resources"
  value       = null_resource.cli_resource.id
}
