# AWS プロバイダーの設定

provider "aws" {
  region  = "ap-northeast-1"
  profile = "dev"

  # すべてのリソースにデフォルトタグを適用
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
      Owner       = var.owner
      ConstCenter = var.cost_center
    }
  }
}


# 現在のAWSカラーアイデンティティを取得
data "aws_caller_identity" "current" {}

# 利用可能なアベイラビリティゾーンを取得
data "aws_availability_zones" "available" {
  state = "available"
}