# セットアップ手順 / Setup Steps

このドキュメントは、Terraformを使用してEKSクラスタを構築し、`kubectl`でアクセスするまでの手順を説明します。
This document explains the steps to build an EKS cluster using Terraform and access it with `kubectl`.

---

## 1. 前提条件 / Prerequisites

この手順を実行する前に、お使いの環境に以下のツールがインストールされ、設定済みであることを確認してください。
Before proceeding, please ensure the following tools are installed and configured on your system.

- **Terraform:** (https://www.terraform.io/downloads.html)
- **AWS CLI:** (https://aws.amazon.com/cli/)
  - Terraformを実行するIAMユーザーまたはロールの認証情報が設定済みであること。
  - AWS CLI should be configured with credentials for the IAM user or role that will run Terraform.
- **kubectl:** (https://kubernetes.io/docs/tasks/tools/install-kubectl/)

---

## 2. TerraformによるEKSクラスタの構築 / Deploying the EKS Cluster with Terraform

### Step 2.1: Terraformの初期化 / Initialize Terraform

まず、Terraformのワーキングディレクトリを初期化します。これにより、必要なプロバイダプラグインがダウンロードされます。
First, initialize the Terraform working directory. This will download the necessary provider plugins.

```sh
terraform init
```

### Step 2.2: 実行計画の確認 / Review the Execution Plan

次に、どのようなリソースが作成・変更されるかを確認するための実行計画を生成します。
Next, generate an execution plan to see what resources will be created or modified.

```sh
terraform plan
```
このコマンドの出力を確認し、意図した通りの変更が行われることを確認してください。
Review the output of this command to ensure the changes are what you intend.

### Step 2.3: 変更の適用 / Apply the Changes

計画に問題がなければ、変更を適用してAWS上にリソースを構築します。
If the plan is acceptable, apply the changes to build the resources on AWS.

```sh
terraform apply
```
確認のプロンプトが表示されたら、`yes`と入力して実行します。
When prompted for confirmation, type `yes` to proceed.

---

## 3. Kubernetesクラスタへのアクセス / Accessing the Kubernetes Cluster

### Step 3.1: 接続コマンドの取得 / Get the Configuration Command

`terraform apply`が完了すると、EKSクラスタへの接続情報を設定するためのコマンドがTerraformの出力として用意されています。以下のコマンドでそれを取得します。
After `terraform apply` is complete, a command to configure access to the EKS cluster is available as a Terraform output. Retrieve it with the following command.

```sh
terraform output configure_kubectl
```

### Step 3.2: kubeconfigの設定 / Configure kubeconfig

前のステップで表示された`aws eks update-kubeconfig ...`で始まるコマンドをコピーし、ターミナルで実行します。
Copy the command starting with `aws eks update-kubeconfig ...` that was displayed in the previous step, and execute it in your terminal.

**コマンド実行例 (Example):**
```sh
$(terraform output -raw configure_kubectl)
```
*(上記コマンドは `terraform output` の結果を直接実行します。)*
*(The command above directly executes the result of `terraform output`.)*

このコマンドは、`~/.kube/config`ファイルにクラスタへの接続情報を自動的に書き込みます。
This command will automatically write the cluster connection information to your `~/.kube/config` file.

### Step 3.3: 接続の確認 / Verify the Connection

最後に、以下のコマンドを実行して、クラスタに正常に接続できることを確認します。
Finally, run the following command to verify that you can connect to the cluster successfully.

```sh
kubectl get nodes
```
ワーカーノードのリストが表示されれば、セットアップは完了です。
If a list of worker nodes is displayed, the setup is complete.
