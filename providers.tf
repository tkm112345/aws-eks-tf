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

