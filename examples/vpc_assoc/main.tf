locals {
  cli_flags = "--hosted-zone-id ${aws_route53_zone.this.id} --vpc VPCRegion=${var.region},VPCId=${data.aws_vpc.peer.id}"
}

####################################################################################################
# Data lookups
####################################################################################################

data "aws_vpc" "owner" {
  provider = aws.owner
  default  = true
}

data "aws_vpc" "peer" {
  provider = aws.peer
  default  = true
}

####################################################################################################
# Zone owner
# ----------
# Setup for the account that owns the zone that needs to be shared.
####################################################################################################

resource "aws_route53_zone" "this" {
  provider = aws.owner
  name     = "example.org"

  vpc {
    vpc_id = data.aws_vpc.owner.id
  }
}

resource "aws_route53_record" "www" {
  provider = aws.owner
  zone_id  = aws_route53_zone.this.id
  name     = "google.example.org"
  type     = "A"
  ttl      = "10"
  records  = ["8.8.8.8"]
}

module "create_vpc_association_authorization" {
  source    = "../.."
  providers = { aws = aws.owner }

  role_arn    = var.zone_owner_account_role
  cmd         = "aws route53 create-vpc-association-authorization ${local.cli_flags}"
  destroy_cmd = "aws route53 delete-vpc-association-authorization ${local.cli_flags}"
}

####################################################################################################
# Associated VPC
# ----------
# Setup for the account that has a VPC which should include the exported zone
####################################################################################################

module "associate_vpc_with_zone" {
  source    = "../.."
  providers = { aws = aws.peer }

  role_arn    = var.peer_vpc_account_role
  cmd         = "aws route53 associate-vpc-with-hosted-zone ${local.cli_flags}"
  destroy_cmd = "aws route53 disassociate-vpc-from-hosted-zone ${local.cli_flags}"

  dependency_ids = [
    module.create_vpc_association_authorization.id,
    aws_route53_zone.this.id
  ]
}

