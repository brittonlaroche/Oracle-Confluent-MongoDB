
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  create_database_subnet_group = true

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3"

  name        = local.name
  description = "Complete Oracle example security group"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = " all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = " all"
    cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.tags
}

module ec2 {
  source= "terraform-aws-modules/ec2-instance/aws"

  ami                    = "ami-00aa9d3df94c6c354"
  instance_type          = "t2.micro"
  key_name               = var.ec2_key_name
  monitoring             = true
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  tags = local.tags
}

module "db" {
  source = "terraform-aws-modules/rds/aws" 

  
  identifier = "leg"

  engine               = "oracle-se2"
  engine_version       = "19"
  family               = "oracle-se2-19" # DB parameter group
  major_engine_version = "19"           # DB option group
  instance_class       = "db.t3.large"
  license_model        = "bring-your-own-license"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  db_name                = "ORCL"
  username               = var.oracle_username
  create_random_password = true
  random_password_length = 12
  port                   = 1521
  # db_subnet_group_name = module.vpc.database_subnets.database_

  multi_az               = false
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
  publicly_accessible = true
  db_subnet_group_name = module.vpc.name

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  # enabled_cloudwatch_logs_exports = ["alert", "audit"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = false

  # See here for support character sets https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.OracleCharacterSets.html
  character_set_name = "AL32UTF8"

  tags = local.tags
}
