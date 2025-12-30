# main.tf
# EKSクラスターとノードグループのメイン設定

# KMSキー（EKSクラスター暗号化用）
resource "aws_kms_key" "eks" {
  count = var.enable_cluster_encryption ? 1 : 0

  description             = "EKS Secret Encryption Key for ${var.project_name}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-eks-encryption-key"
    },
    var.additional_tags
  )
}

resource "aws_kms_alias" "eks" {
  count = var.enable_cluster_encryption ? 1 : 0

  name          = "alias/${var.project_name}-${var.environment}-eks-encryption-key"
  target_key_id = aws_kms_key.eks[0].key_id
}

# EKSクラスター
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # クラスター基本設定
  cluster_name                    = local.cluster_name
  cluster_version                 = var.kubernetes_version
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # クラスターエンドポイントへのアクセス制御
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # VPC設定
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # 暗号化設定
  cluster_encryption_config = var.enable_cluster_encryption ? {
    resources = ["secrets"]
    provider = {
      key_arn = aws_kms_key.eks[0].arn
    }
  } : null

  # CloudWatch Logs設定
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = 14

  # クラスター作成者に管理者権限を付与
  enable_cluster_creator_admin_permissions = true

  # IRSA（IAM roles for service accounts）を有効化
  enable_irsa = true

  # EKS管理ノードグループ
  eks_managed_node_groups = {
    # メインノードグループ
    main = {
      name            = "${var.project_name}-${var.environment}-main"
      use_name_prefix = false

      # ノード設定
      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type

      # スケーリング設定
      min_size     = var.node_group_min_capacity
      max_size     = var.node_group_max_capacity
      desired_size = var.node_group_desired_capacity

      # AMI設定
      ami_type = var.node_group_ami_type

      # ディスク設定
      disk_size = var.node_group_disk_size

      # ネットワーク設定
      subnet_ids = module.vpc.private_subnets

      # セキュリティグループ
      vpc_security_group_ids = [aws_security_group.additional_eks.id]

      # タグ設定
      tags = merge(
        {
          Name          = "${var.project_name}-${var.environment}-main-node"
          NodeGroupRole = "main"
        },
        var.additional_tags
      )
    }
  }

  # EKSアドオン
  cluster_addons = {
    # Amazon VPC CNI
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          # IPv4プールサイズの最適化
          WARM_ENI_TARGET   = "1"
          WARM_IP_TARGET    = "10"
          MINIMUM_IP_TARGET = "2"
        }
      })
    }

    # CoreDNS
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "Fargate"
        # リソース制限の設定
        resources = {
          limits = {
            cpu    = "0.25"
            memory = "256Mi"
          }
          requests = {
            cpu    = "0.25"
            memory = "256Mi"
          }
        }
      })
    }

    # kube-proxy
    kube-proxy = {
      most_recent = true
    }

    # AWS EBS CSI Driver
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.irsa_ebs_csi.iam_role_arn
    }

    # Pod Identity Agent（新しいIRSAの実装）
    eks-pod-identity-agent = {
      before_compute = true
      most_recent    = true
    }
  }

  # ノードグループのデフォルト設定
  eks_managed_node_group_defaults = {
    # AMI設定
    ami_type = var.node_group_ami_type

    # インスタンス設定
    instance_types = var.node_group_instance_types
    capacity_type  = var.node_group_capacity_type

    # セキュリティ設定
    vpc_security_group_ids = [aws_security_group.additional_eks.id]

    # IAMポリシーの追加設定
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    # メタデータ設定（セキュリティ強化）
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      instance_metadata_tags      = "disabled"
    }
  }

  # タグ設定
  tags = merge(
    {
      Environment = var.environment
      GithubRepo  = "terraform-aws-eks"
      GithubOrg   = "terraform-aws-modules"
    },
    var.additional_tags
  )
}

# EBS CSI Driver用のIRSA
module "irsa_ebs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.project_name}-${var.environment}-ebs-csi-driver"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-ebs-csi-driver-role"
    },
    var.additional_tags
  )
}

# Karpenter用のモジュール
module "karpenter" {

  count             = var.karpenter_enabled ? 1 : 0
  source            = "./modules/karpenter"
  cluster_name      = local.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  tags              = var.additional_tags
}