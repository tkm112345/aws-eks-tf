locals {
  # クラスター名の生成
  cluster_name = "${var.project_name}-${var.environment}-eks"

  # 使用するアベイラビリティゾーンの数を決定
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # 共通タグの定義
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    },
    var.additional_tags
  )

  # EKS用タグ（Kubernetesリソース用）
  eks_cluster_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

}