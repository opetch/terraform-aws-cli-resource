terraform {
  required_version = ">= 0.12"
}

data "aws_caller_identity" "id" {
}

locals {
  account_id      = var.account_id == null ? data.aws_caller_identity.id.account_id : var.account_id
  assume_role_cmd = "source ${path.module}/assume_role.sh ${local.account_id} ${var.role_arn}"
}

resource "null_resource" "cli_resource" {
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash -c '${var.role_arn == null ? "" : "${local.assume_role_cmd} && "}${var.cmd}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "/bin/bash -c '${var.role_arn == null ? "" : "${local.assume_role_cmd} && "}${var.destroy_cmd}'"
  }

  # By depending on the null_resource, the cli resource effectively depends on the existance
  # of the resources identified by the ids provided via the dependency_ids list variable.
  depends_on = [null_resource.dependencies]
}

resource "null_resource" "dependencies" {
  triggers = {
    dependencies = join(",", var.dependency_ids)
  }
}
