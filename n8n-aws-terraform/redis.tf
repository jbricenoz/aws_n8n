// redis.tf
// Amazon ElastiCache Redis for n8n queue mode (scaling)

resource "aws_elasticache_subnet_group" "n8n_redis_subnet_group" {
  name       = "n8n-redis-subnet-group"
  subnet_ids = local.private_subnet_ids
}

resource "aws_elasticache_cluster" "n8n_redis" {
  cluster_id           = "n8n-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.n8n_redis_subnet_group.name
  security_group_ids   = [aws_security_group.n8n_redis_sg.id]
  port                 = 6379
  tags = {
    Name = "n8n-redis"
  }
}

resource "aws_security_group" "n8n_redis_sg" {
  name        = "n8n-redis-sg"
  description = "Allow Redis access from EC2 only"
  vpc_id      = local.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.n8n_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "n8n-redis-sg"
  }
}
