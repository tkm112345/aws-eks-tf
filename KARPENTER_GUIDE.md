# Karpenter 統合ガイド / Karpenter Integration Guide

このドキュメントでは、このTerraformプロジェクト内でKarpenterモジュールを有効化し、設定する方法について説明します。
This document explains how to enable and configure the Karpenter module within this Terraform project.

---

## はじめに / Introduction

[Karpenter](https://karpenter.sh/) は、アプリケーションの可用性とクラスターの効率を向上させる、オープンソースの高性能なKubernetesクラスターオートスケーラーです。
[Karpenter](https://karpenter.sh/) is an open-source, high-performance Kubernetes cluster autoscaler that helps improve application availability and cluster efficiency.

このプロジェクトには、Karpenterに必要なAWS IAMリソースを作成するためのオプションのTerraformモジュールが含まれています。
This project includes an optional Terraform module to create the necessary AWS IAM resources for Karpenter.

このガイドはTerraformに関する部分を説明します。
This guide covers the Terraform part.

Terraformの変更を適用した後、Helmを使ってKarpenterアプリケーション（コントローラー）をクラスターにデプロイする作業が別途必要になります。
After applying the Terraform changes, you will still need to deploy the Karpenter application (controller) to your cluster using Helm.

---

## ステップ1: Karpenterモジュールを有効化する / Step 1: Enable the Karpenter Module

Karpenter用のIAMリソース作成を有効にするには、`terraform.tfvars` ファイルを作成（または既存のファイルを編集）し、`karpenter_enabled` 変数を `true` に設定します。
To enable the creation of Karpenter's IAM resources, create a `terraform.tfvars` file (or edit your existing one) and set the `karpenter_enabled` variable to `true`.

**`terraform.tfvars`**
```hcl
karpenter_enabled = true
```

---

## ステップ2: Karpenter用に初期ノードグループを調整する / Step 2: Adjust the Initial Node Group for Karpenter

Karpenterを使用する場合、アプリケーションに起因する全てのノードスケーリングをKarpenterに任せることがベストプラクティスです。
When using Karpenter, it is a best practice to let Karpenter handle all application-driven node scaling.

静的に定義された初期ノードグループ（このプロジェクトでは `main` という名前）は、1台のノードに「固定」されるべきです。
The initial, statically-defined node group (named `main` in this project) should be "locked" to a single node.

このノードの唯一の目的は、重要なシステムPodとKarpenterコントローラー自身を実行することです。
This node's only purpose is to run critical system pods and the Karpenter controller itself.

これを設定するために、`terraform.tfvars` ファイルでノードグループのキャパシティに関する変数を以下のように設定します。
To configure this, set the node group capacity variables as follows in your `terraform.tfvars` file.

**`terraform.tfvars`**
```hcl
# Karpenterを有効化 / Enable Karpenter
karpenter_enabled = true

# 初期マネージドノードグループを単一ノードに固定 / Lock the initial managed node group to a single node
node_group_min_capacity     = 1
node_group_desired_capacity = 1
node_group_max_capacity     = 1
```

これにより、EKSマネージドノードグループ自身のオートスケーラーがKarpenterと競合するのを防ぎます。
This prevents the EKS Managed Node Group's own autoscaler from competing with Karpenter.

---

## ステップ3: Terraformを適用し、HelmでKarpenterをデプロイする / Step 3: Apply Terraform and Deploy Karpenter via Helm

### 1. Terraformの適用 / Apply Terraform

`terraform apply` を実行します。
Run `terraform apply`.

これにより、EKSクラスターと共に、Karpenterにとって重要な2つのIAMロールが作成されます。
This will create the EKS cluster along with two critical IAM roles for Karpenter:
*   `KarpenterControllerRole-<cluster_name>`: KarpenterコントローラーのPodがIRSAを介して引き受けるロール。 / The role assumed by the Karpenter controller pod via IRSA.
*   `KarpenterNodeRole-<cluster_name>`: KarpenterがプロビジョニングするEC2ノードが引き受けるロール。 / The role assumed by the EC2 nodes that Karpenter provisions.

### 2. Karpenterのデプロイ / Deploy Karpenter

Terraformの適用が完了した後、EKSクラスターにKarpenterをインストールする必要があります。
After Terraform completes, you must install Karpenter into your EKS cluster.

これは公式のHelmチャートを使用して行います。
This is done using the official Helm chart.

Terraformによって作成されたIAMロールは、Helmインストール時に指定します。
The IAM role created by Terraform is passed to the Helm chart during installation.

KarpenterのHelmチャートをインストールするための最新かつ詳細な手順については、**公式Karpenterドキュメント** を参照してください。
For detailed, up-to-date instructions on installing the Karpenter Helm chart, please refer to the **official Karpenter Documentation**.
*   **[Karpenter スタートガイド / Karpenter Getting Started Guide](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/)**

このHelmをインストールする際に、`NodePools` と `EC2NodeClasses` を（YAMLファイルで）定義します。これにより、Karpenterがどのような種類のノードをプロビジョニングしてよいかを指定します。
The Helm installation is where you will define the `NodePools` and `EC2NodeClasses` (in YAML files) that tell Karpenter what kind of nodes it is allowed to provision.