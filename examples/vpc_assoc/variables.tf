variable "region" {
  description = "The target region for both accounts"
  default     = "eu-central-1"
}

variable "zone_owner_account_role" {
  description = "The account role ARN to assume in order to run the cli command against the owner account"
}

variable "peer_vpc_account_role" {
  description = "The remote account role ARN to assume in order to run the cli command against the remote account"
}
