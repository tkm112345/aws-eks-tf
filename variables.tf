# すべての入力変数を定義

# 基本設定
variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "環境 (dev, staging, prod)"
  type        = string
  default     = "personal"
  validation {
    condition     = contains(["personal", "dev", "staging", "prod"], var.environment)
    error_message = "Environment must be personal, dev, staging, prod."
  }
}

variable "project_name" {
  description = "プロジェクト名"
  type        = string
  default     = "my-eks-project"
}

variable "owner" {
  description = "リソースの所有者"
  type        = string
  default     = "aws-eks-admin"
}

variable "cost_center" {
  description = "コストセンター"
  type        = string
  default     = "CC1001"
}

# EKSクラスター設定
variable "kubernetes_version" {
  description = "Kubernetesバージョン"
  type        = string
  default     = "1.33"
}

variable "cluster_endpoint_public_access" {
  description = "EKSクラスターのパブリックエンドポイントアクセスを有効にするかどうか"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "EKSクラスターのプライベートエンドポイントアクセスを有効にするかどうか"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "EKSクラスターのパブリックエンドポイントにアクセスを許可するCIDRブロックのリスト"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ノードグループ設定
variable "node_group_instance_types" {
  description = "EKSノードグループのインスタンスタイプ"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_group_capacity_type" {
  description = "EKSノードグループのキャパシティタイプ (ON_DEMANDまたはSPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_group_capacity_type)
    error_message = "Node group capacity type must be ON_DEMAND or SPOT."
  }
}

variable "node_group_ami_type" {
  description = "EKSノードグループのAMIタイプ"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_group_disk_size" {
  description = "ワーカーノードのディスクサイズ(GB)"
  type        = number
  default     = 10
}

variable "node_group_desired_capacity" {
  description = "EKSノードグループの希望するキャパシティ"
  type        = number
  default     = 1
}

variable "node_group_max_capacity" {
  description = "ワーカーノードの最大数"
  type        = number
  default     = 1
}

variable "node_group_min_capacity" {
  description = "ワーカーノードの最小数"
  type        = number
  default     = 1
}

# VPC設定
variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "NAT Gatewayを有効にするかどうか"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "単一のNAT Gatewayを使用するかどうか（コスト削減のため）"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "VPCでDNSホスト名を有効にするかどうか"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "VPCでDNSサポートを有効にするかどうか"
  type        = bool
  default     = true
}


# セキュリティ設定
variable "enable_cluster_encryption" {
  description = "EKSクラスターの暗号化を有効にするかどうか"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "有効にするEKSクラスタのログタイプ"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# タグ設定
variable "additional_tags" {
  description = "追加のタグ"
  type        = map(string)
  default     = {}
}