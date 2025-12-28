# vpc.tf
# VPCおよび関連ネットワークリソースの定義



# VPCモジュールを使用してネットワークインフラを作成
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  # VPC基本設定
  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  # アベイラビリティゾーンとサブネット設定
  azs = local.azs

  # プライベートサブネット（ワーカーノード用）
  private_subnets = [
    for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  # パブリックサブネット（Load Balancer用）
  public_subnets = [
    for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 10)
  ]

  # NAT Gateway設定
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # DNS設定（EKSで必要）
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # EKS用のプライベートサブネットタグ
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  # VPCタグ
  tags = merge(
    {
      Name                                          = "${var.project_name}-${var.environment}-vpc"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    },
    var.additional_tags
  )

  # VPCエンドポイント設定（コスト最適化のため、必要に応じてコメントアウト）
  # enable_s3_endpoint       = true
  # enable_dynamodb_endpoint = true
}

# EKS専用のセキュリティグループルール（追加のカスタマイゼーション用）
resource "aws_security_group" "additional_eks" {
  name_prefix = "${var.project_name}-${var.environment}-eks-additional"
  vpc_id      = module.vpc.vpc_id

  description = "Additional security group for EKS cluster"

  # アウトバウンドHTTPS（Kubernetesアップデート用）
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンドHTTP（パッケージダウンロード用）
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS用UDP
  egress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS用TCP
  egress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-eks-additional-sg"
    },
    var.additional_tags
  )
}