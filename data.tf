# データソースの定義

# 現在のAWSアカウント情報を取得
data "aws_caller_identity" "current" {}

# 現在のAWSリージョン情報を取得
data "aws_region" "current" {}

# 指定されたリージョンで利用可能なアベイラビリティゾーンを取得
data "aws_availability_zones" "available" {
  state = "available"
}

# EKS用のAMI情報を取得 (ノードグループで使用する最新AMI)
data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_name

    depends_on = [module.eks]
}

# EKSクラスタの詳細情報を取得
data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_name

    depends_on = [module.eks]
}

# TLS証明書の取得 (OIDC Provider用)
data "tls_certificate" "cluster" {
    url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# EKS最適化AMIの取得
data "aws_ami" "eks_default" {
    most_recent = true
    owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kubernetes_version}-v*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC CNI最新バージョンの取得
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

# CoreDNS最新バージョンの取得
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

# kube-proxy最新バージョンの取得
data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

# EBS CSI Driver最新バージョンの取得
data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

# 現在のユーザー情報（出力用）
data "aws_iam_user" "current" {
  count     = length(regexall("^arn:aws:iam::[0-9]+:user/", data.aws_caller_identity.current.arn))
  user_name = split("/", data.aws_caller_identity.current.arn)[1]
}

# 現在のロール情報（出力用）
data "aws_iam_role" "current" {
  count = length(regexall("^arn:aws:iam::[0-9]+:role/", data.aws_caller_identity.current.arn))
  name  = split("/", data.aws_caller_identity.current.arn)[1]
}