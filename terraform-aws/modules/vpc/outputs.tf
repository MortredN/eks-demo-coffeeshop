output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_ids" {
  value = {
    eks1    = aws_subnet.eks1_subnet.id
    eks2    = aws_subnet.eks2_subnet.id
    rds1    = aws_subnet.rds1_subnet.id
    rds2    = aws_subnet.rds2_subnet.id
    alb1    = aws_subnet.alb1_subnet.id
    alb2    = aws_subnet.alb2_subnet.id
    bastion = aws_subnet.bastion_subnet.id
    natgw   = aws_subnet.natgw_subnet.id
  }
}

output "subnet_arns" {
  value = {
    eks1    = aws_subnet.eks1_subnet.arn
    eks2    = aws_subnet.eks2_subnet.arn
    rds1    = aws_subnet.rds1_subnet.arn
    rds2    = aws_subnet.rds2_subnet.arn
    alb1    = aws_subnet.alb1_subnet.arn
    alb2    = aws_subnet.alb2_subnet.arn
    bastion = aws_subnet.bastion_subnet.arn
    natgw   = aws_subnet.natgw_subnet.arn
  }
}

output "route_table_ids" {
  value = {
    private = aws_route_table.private_rtb.id
    public  = aws_route_table.public_rtb.id
    bastion = aws_route_table.bastion_rtb.id
  }
}
