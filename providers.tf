# AWS プロバイダーの設定

provider "aws" {
  region  = var.aws_region  # 必要に応じてAWSリージョンを指定
  profile = var.aws_profile # 必要に応じてAWS CLIのプロファイルを指定


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

