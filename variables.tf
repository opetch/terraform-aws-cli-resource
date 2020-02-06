variable "cmd" {
  description = "The command used to create the resource."
  type        = string
}

variable "destroy_cmd" {
  description = "The command used to destroy the resource."
  type        = string
}

variable "account_id" {
  description = "The account that holds the role to assume in. Will use providers account by default"
  type        = string
  default     = null
}

variable "role_arn" {
  description = "The role to assume in order to run the cli command."
  type        = string
  default     = null
}

variable "dependency_ids" {
  description = "IDs or ARNs of any resources that are a dependency of the resource created by this module."
  type        = list(string)
  default     = []
}
