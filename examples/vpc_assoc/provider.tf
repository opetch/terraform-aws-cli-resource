provider "null" {
  version = "~> 2.1"
}

provider "aws" {
  region = var.region
  alias  = "owner"
  assume_role {
    role_arn = var.zone_owner_account_role
  }
}

provider "aws" {
  region  = var.region
  alias   = "peer"
  version = "~> 2.47"
  assume_role {
    role_arn = var.peer_vpc_account_role
  }
}
