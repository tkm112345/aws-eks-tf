# outputs.tf
# 出力値の定義

# EKSクラスター情報
output "cluster_id" {
  description = "EKSクラスターのID"
  value       = module.eks.cluster_name
}

output "cluster_name" {
  description = "EKSクラスターの名前"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "EKSクラスターのARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "EKSコントロールプレーンのエンドポイント"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "EKSクラスターのKubernetesバージョン"
  value       = module.eks.cluster_version
}

output "cluster_platform_version" {
  description = "EKSクラスターのプラットフォームバージョン"
  value       = module.eks.cluster_platform_version
}

# セキュリティグループ
output "cluster_security_group_id" {
  description = "EKSクラスターに接続されたセキュリティグループID"
  value       = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "EKSクラスターのプライマリセキュリティグループID"
  value       = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "ノード共有セキュリティグループのID"
  value       = module.eks.node_security_group_id
}

# IAMロール
output "cluster_iam_role_name" {
  description = "EKSクラスターのIAMロール名"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "EKSクラスターのIAMロールARN"
  value       = module.eks.cluster_iam_role_arn
}

# OIDC Provider
output "oidc_provider_arn" {
  description = "EKS OIDC プロバイダーのARN (IRSA有効時)"
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "EKSクラスターのOIDC発行者URL"
  value       = module.eks.cluster_oidc_issuer_url
}

# ノードグループ
output "eks_managed_node_groups" {
  description = "EKS管理ノードグループの情報"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "EKS管理ノードグループによって作成されたオートスケーリンググループ名"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

# VPC情報
output "vpc_id" {
  description = "VPCのID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "プライベートサブネットのID"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "パブリックサブネットのID"
  value       = module.vpc.public_subnets
}

# CloudWatch Log Group
output "cloudwatch_log_group_name" {
  description = "EKSクラスターのCloudWatch Log Group名"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "EKSクラスターのCloudWatch Log Group ARN"
  value       = module.eks.cloudwatch_log_group_arn
}

# kubectl設定コマンド
output "configure_kubectl" {
  description = "kubectlを設定するためのコマンド"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}

# 接続情報
output "cluster_status" {
  description = "EKSクラスターの状態"
  value       = module.eks.cluster_status
}

# KMS
output "kms_key_arn" {
  description = "EKS暗号化で使用されるKMSキーのARN"
  value       = try(module.eks.kms_key_arn, null)
}

output "kms_key_id" {
  description = "EKS暗号化で使用されるKMSキーのID"
  value       = try(module.eks.kms_key_id, null)
}