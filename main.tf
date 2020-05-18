variable role_arn {
  description = "The role ARN to assume in order to run the cli command."
  default     = ""
}

variable "region" {
  description = "AWS region to run the CLI command"
}

variable cmd {
  description = "The command used to create the resource."
}

variable destroy_cmd {
  description = "The command used to destroy the resource."
}

variable dependency_ids {
  description = "IDs or ARNs of any resources that are a dependency of the resource created by this module."
  type        = list(string)
  default     = []
}

resource "null_resource" "cli_resource" {
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash -c '${self.triggers.pre_cmd}${self.triggers.cmd}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "/bin/bash -c '${self.triggers.pre_cmd}${self.triggers.cmd}'"
  }

  # By depending on the null_resource, the cli resource effectively depends on the existance
  # of the resources identified by the ids provided via the dependency_ids list variable.
  depends_on = [null_resource.dependencies]

  triggers = {
    # Terraform 12 does not allow direct references to "var.*" in provisioners, but does to "self.*",
    # so setting commands here instead of directly in provisioner
    pre_cmd = "${var.role_arn == "" ? "" : "source ${path.module}/assume_role.sh ${var.role_arn} && "}"
    cmd     = "aws --region ${var.region} ${var.cmd}"
  }
}

resource "null_resource" "dependencies" {
  triggers = {
    dependencies = "${join(",", var.dependency_ids)}"
  }
}

output "id" {
  description = "The ID of the null_resource used to provison the resource via cli. Useful for creating dependencies between cli resources"
  value       = null_resource.cli_resource.id
}
