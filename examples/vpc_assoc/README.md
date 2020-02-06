# README

This demonstrates cross account VPC association for Route 53 zones.

The example creates a zone for "example.org" in the owner account, using the credentials in the varaible `zone_owner_account_role`. This should be an admin account for convenience.

It then creates an A-record called "google" that points to the Google global DNS server.

Next it creates a VPC association between the owners default VPC and th the peer account's default VPC, using the credentials in the varaible `peer_vpc_account_role`. This should be an admin account for convenience.

Machines in the peer default VPC can now lookup "google.example.org" and see the IP address "8.8.8.8".
