terraform {
  required_version = ">= 0.12"
}

locals {
  assume_role_cmd = var.role_arn == null ? "" : "source ${path.module}/assume_role.sh ${var.role_arn}"
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
