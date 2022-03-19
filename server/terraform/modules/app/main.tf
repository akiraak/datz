# ================================================
# VPC
# ================================================
variable "vpc" {
  default = {
    "vpc_cidr_block" = "10.0.0.0/16"
    "subnet_public_management_1_cidr_block" = "10.0.240.0/24"
    "subnet_public_management_2_cidr_block" = "10.0.241.0/24"
    "subnet_public_app_alb_1_cidr_block" = "10.0.0.0/24"
    "subnet_public_app_alb_2_cidr_block" = "10.0.1.0/24"
    "subnet_private_app_1_cidr_block" = "10.0.8.0/24"
    "subnet_private_app_2_cidr_block" = "10.0.9.0/24"
    "subnet_private_app_db_1_cidr_block" = "10.0.16.0/24"
    "subnet_private_app_db_2_cidr_block" = "10.0.17.0/24"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}"
  }
}

# ================================================
# Internet gateway & Root table
# ================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ================================================
# Subnet: Public management
# ================================================
resource "aws_subnet" "public_management_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_public_management_1_cidr_block
  availability_zone = var.az_1
  tags = {
    Name = "${var.name}-public-management-1"
  }
}

resource "aws_subnet" "public_management_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_public_management_2_cidr_block
  availability_zone = var.az_2
  tags = {
    Name = "${var.name}-public-management-2"
  }
}

resource "aws_route_table_association" "public_management_1" {
  subnet_id      = aws_subnet.public_management_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_management_2" {
  subnet_id      = aws_subnet.public_management_2.id
  route_table_id = aws_route_table.public.id
}

# ================================================
# Subnet: Public app alb
# ================================================
resource "aws_subnet" "public_app_alb_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_public_app_alb_1_cidr_block
  availability_zone = var.az_1
  tags = {
    Name = "${var.name}-public-app-alb-1"
  }
}

resource "aws_subnet" "public_app_alb_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_public_app_alb_2_cidr_block
  availability_zone = var.az_2
  tags = {
    Name = "${var.name}-public-app-alb-2"
  }
}

resource "aws_route_table_association" "public_app_alb_1" {
  subnet_id      = aws_subnet.public_app_alb_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_app_alb_2" {
  subnet_id      = aws_subnet.public_app_alb_2.id
  route_table_id = aws_route_table.public.id
}

# ================================================
# NAT gateway & Elastic IP & Root table
# ================================================
resource "aws_eip" "ngw" {
  vpc = true
  tags = {
    Name = "${var.name}-ngw"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public_app_alb_1.id

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    nat_gateway_id = aws_nat_gateway.main.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "${var.name}-private"
  }
}

# ================================================
# Subnet: Private app
# ================================================
resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_private_app_1_cidr_block
  availability_zone = var.az_1
  tags = {
    Name = "${var.name}-private-app-1"
  }
}

resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_private_app_2_cidr_block
  availability_zone = var.az_2
  tags = {
    Name = "${var.name}-private-app-2"
  }
}

resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private.id
}

# ================================================
# Subnet: Private app db
# ================================================
resource "aws_subnet" "private_app_db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_private_app_db_1_cidr_block
  availability_zone = var.az_1
  tags = {
    Name = "${var.name}-private-app-db-1"
  }
}

resource "aws_subnet" "private_app_db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc.subnet_private_app_db_2_cidr_block
  availability_zone = var.az_2
  tags = {
    Name = "${var.name}-private-app-db-2"
  }
}

# ================================================
# Security group: management
# ================================================
resource "aws_security_group" "management" {
  name                   = "${var.name}-management"
  vpc_id                 = aws_vpc.main.id
  revoke_rules_on_delete = false

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-management"
  }
}

# ssh
resource "aws_security_group_rule" "app_permit_ssh" {
  security_group_id = aws_security_group.management.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
}

# ================================================
# Security group: app alb
# ================================================
resource "aws_security_group" "app_alb" {
  name                   = "${var.name}-app-alb"
  vpc_id                 = aws_vpc.main.id
  revoke_rules_on_delete = false

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app-alb"
  }
}

# http
resource "aws_security_group_rule" "alb_permit_from_internet_http" {
  security_group_id = aws_security_group.app_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit from internet for http."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
}

# https
resource "aws_security_group_rule" "alb_permit_from_internet_https" {
  security_group_id = aws_security_group.app_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit from internet for https."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
}

# ================================================
# Security group: app
# ================================================
resource "aws_security_group" "app" {
  name                   = "${var.name}-app"
  vpc_id                 = aws_vpc.main.id
  revoke_rules_on_delete = false

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app"
  }
}

# http
resource "aws_security_group_rule" "app_permit_from_app_alb_http" {
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.app_alb.id
  description              = "permit from alb."
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "80"
  to_port                  = "80"
}

# ssh
resource "aws_security_group_rule" "app_permit_from_management_ssh" {
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.management.id
  description              = "permit from management."
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "22"
  to_port                  = "22"
}

# ================================================
# Security group: app db
# ================================================
resource "aws_security_group" "app_db" {
  name                   = "${var.name}-app-db"
  vpc_id                 = aws_vpc.main.id
  revoke_rules_on_delete = false
  tags = {
    Name = "${var.name}-app-db"
  }
}

resource "aws_security_group_rule" "app-db-sg-rule-mysql-from-app" {
  security_group_id = aws_security_group.app_db.id
  type = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app-db-sg-rule-mysql-from-management" {
  security_group_id = aws_security_group.app_db.id
  type = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.management.id
}

# ALBアカウントIDを取得するために使用
data "aws_elb_service_account" "main" {}

# ================================================
# ログ格納用バケットポリシー
# ================================================
data "aws_iam_policy_document" "logging_bucket" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = [
        data.aws_elb_service_account.main.arn
      ]
      type        = "AWS"
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${var.name}-logging",
      "arn:aws:s3:::${var.name}-logging/*"
    ]
  }
}

# ================================================
# ログ格納用バケット
# ================================================
resource "aws_s3_bucket" "logging" {
  bucket = "${var.name}-logging"
  policy = data.aws_iam_policy_document.logging_bucket.json ## iam.tfで設定したポリシーを使用。
  force_destroy = true
  /*
  versioning {
    enabled    = true
    mfa_delete = false
  }
  */

  ## オブジェクトのライフサイクル設定。
  lifecycle_rule {
    id      = "assets"
    enabled = true

    ## オブジェクトの保存期限。
    expiration {
      days = "365" ## 1年
    }

    ## 現在のオブジェクトの移行設定。
    transition {
      ## オブジェクトが作成されてから移行するまでの日数。
      days          = "93" ## 3ヶ月
      storage_class = "STANDARD_IA"
    }

    ## オブジェクトの以前のバージョンの保存期限。
    noncurrent_version_expiration {
      days = "1095" ## 3年
    }

    ## 古いのオブジェクトの移行設定。
    noncurrent_version_transition {
      ## オブジェクトが古いバージョンになってから移行するまでの日数。
      days          = "365" ## 1年
      storage_class = "GLACIER"
    }
  }

  request_payer = "BucketOwner"
}

resource "aws_s3_bucket_versioning" "logging" {
  bucket = aws_s3_bucket.logging.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Public Access Block
## パブリックアクセスはしないため全て有効にする。
resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ================================================
# ALB Target group: app
# ================================================
resource "aws_lb_target_group" "app" {
  name        = "${var.name}-tg-app"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  # 登録解除を実行するまでの待機時間。
  deregistration_delay = 300 # 処理中のリクエストの完了するのを待つためにデフォルト値を採用。

  # 登録された後にリクエストを開始する猶予時間
  slow_start = 0 # 登録されたらすぐに開始してよいので無効。

  load_balancing_algorithm_type = "round_robin" # ラウンドロビンで平均的にリクエストを分散。

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400 # 要件が決まっていないのでとりあえず1日を設定。
    enabled         = true
  }

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port" # トラフィックを受信するポートを使用。デフォルト。
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}

# ================================================
# ALB Listener: app
# ================================================
# https
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Listener: HTTPをHTTPSにリダイレクトするためのリスナー
resource "aws_lb_listener" "http_redirect_to_https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ================================================
# ALB: app
# ================================================
resource "aws_lb" "app" {
  name               = "${var.name}-app"
  internal           = false # 内部で使用しないため無効。
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.app_alb.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.logging.bucket
    prefix  = "elb"
    enabled = true
  }

  subnets = [
    aws_subnet.public_app_alb_1.id,
    aws_subnet.public_app_alb_2.id
  ]

  idle_timeout               = 60    # デフォルトの60秒を設定。
  enable_deletion_protection = false # Terraformで削除したいため無効。
  enable_http2               = true
  ip_address_type            = "ipv4" # ipv6は使用しないためipv4を指定。
}

# ================================================
# EC2: AMI
# ================================================
data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# ================================================
# EC2: management
# ================================================
resource "aws_instance" "management" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  vpc_security_group_ids      = [aws_security_group.management.id]
  subnet_id                   = aws_subnet.public_management_1.id
  key_name                    = aws_key_pair.management.key_name
  instance_type               = var.instance_type_management
  associate_public_ip_address = "true"

  tags = {
    Name = "${var.name}-management"
  }

  user_data = <<EOF
    #!/bin/bash
    sudo yum -y update
    sudo yum install -y mariadb-server git
  EOF
}

resource "aws_key_pair" "management" {
  key_name   = "${var.name}-key-management"
  public_key = file(var.public_key_path_management)
}

# ================================================
# EC2: app
# ================================================
resource "aws_iam_role" "app" {
    name = "${var.name}-ir-app"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "app" {
    name = "${var.name}-irp-app"
    role = aws_iam_role.app.id
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "app" {
    name = "${var.name}-iip-app"
    role = aws_iam_role.app.name
}

resource "aws_key_pair" "app" {
  key_name   = "${var.name}-key-app"
  public_key = file(var.public_key_path_app)
}

resource "aws_instance" "app" {
  ami                     = data.aws_ssm_parameter.amzn2_ami.value
  vpc_security_group_ids  = [aws_security_group.app.id]
  subnet_id               = aws_subnet.private_app_1.id
  key_name                = aws_key_pair.app.key_name
  instance_type           = var.instance_type_app
  iam_instance_profile    = aws_iam_instance_profile.app.name
  tags = {
    Name = "${var.name}-app"
  }
}


# ================================================
# RDS: app db
# ================================================
resource "aws_db_subnet_group" "app" {
  name        = "${var.name}-app"
  subnet_ids  = ["${aws_subnet.private_app_db_1.id}", "${aws_subnet.private_app_db_2.id}"]
  tags = {
      Name = "${var.name}-app"
  }
}

resource "aws_db_instance" "db" {
  identifier          = "${var.name}-app"
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0.23"
  instance_class      = var.db_instance_type_app
  #name                = "app"
  username            = "root"
  password            = "rootroot"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.app_db.id]
  db_subnet_group_name   = aws_db_subnet_group.app.name
}

# ================================================
# S3 endpoint
# ================================================
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id        = aws_vpc.main.id
  service_name  = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
      Name = "${var.name}-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
  route_table_id  = aws_route_table.private.id
}

# ================================================
# Route53
# ================================================
data "aws_route53_zone" "app" {
  name = "${var.route53_zone_app_name}"
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = data.aws_route53_zone.app.name
  type    = "A"
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
