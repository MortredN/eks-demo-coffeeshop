# Subnet group
resource "aws_db_subnet_group" "default" {
  name = "${var.project_name}-subnet-group"
  subnet_ids = [
    var.subnet_ids.rds1,
    var.subnet_ids.rds2
  ]

  tags = {
    Name = "${var.project_name}-subnet-group"
  }
}


# Security group
resource "aws_security_group" "rds_instance_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "SG of bastion host for RDS instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_cluster_to_rds" {
  security_group_id            = aws_security_group.rds_instance_sg.id
  referenced_security_group_id = var.eks_cluster_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "bastion_to_rds" {
  security_group_id            = aws_security_group.rds_instance_sg.id
  referenced_security_group_id = var.bastion_rds_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}


# RDS instances
resource "aws_db_instance" "rds_db_customer" {
  identifier     = "${var.project_name}-rds-customer"
  engine         = "postgres"
  engine_version = "18.1"

  // Instance Configuration
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  multi_az          = true

  // Database Configuration
  db_name  = "eksdemo_coffeeshop_customer"
  username = "postgres"

  // AWS Secrets Manager managed password
  manage_master_user_password = true

  // Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_instance_sg.id]
  publicly_accessible    = false

  // Backup Configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  skip_final_snapshot     = true

  // Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 0 # Disable enhanced monitoring
  performance_insights_enabled    = false

  tags = {
    Name = "${var.project_name}-rds-customer"
  }
}

resource "aws_db_instance" "rds_db_shopping" {
  identifier     = "${var.project_name}-rds-shopping"
  engine         = "postgres"
  engine_version = "18.1"

  // Instance Configuration
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  multi_az          = true

  // Database Configuration
  db_name  = "eksdemo_coffeeshop_shopping"
  username = "postgres"

  // AWS Secrets Manager managed password
  manage_master_user_password = true

  // Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_instance_sg.id]
  publicly_accessible    = false

  // Backup Configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  skip_final_snapshot     = true

  // Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 0 # Disable enhanced monitoring
  performance_insights_enabled    = false

  tags = {
    Name = "${var.project_name}-rds-shopping"
  }
}
