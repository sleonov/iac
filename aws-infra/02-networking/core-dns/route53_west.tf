resource "aws_route53_zone" "private_west" {
  provider = aws.west
  name     = local.west_private_zone_name

  # Primary VPC association — required at creation time; AWS rejects a private zone with no VPCs.
  # Additional associations use aws_route53_zone_association below.
  vpc {
    vpc_id     = local.west_vpc_id
    vpc_region = var.west_region
  }

  # When aws_route53_zone_association resources exist alongside a vpc block, Terraform sees the
  # extra VPC associations in AWS and tries to remove them from the zone resource on the next plan.
  # ignore_changes = [vpc] tells Terraform to leave VPC association management to the
  # aws_route53_zone_association resources below and not touch the vpc blocks after creation.
  lifecycle {
    ignore_changes = [vpc]
  }
}

# Cross-region association — allows east VPC resources to resolve this zone via VPC peering.
resource "aws_route53_zone_association" "private_west_to_east" {
  provider   = aws.west
  zone_id    = aws_route53_zone.private_west.zone_id
  vpc_id     = local.east_vpc_id
  vpc_region = var.east_region
}
