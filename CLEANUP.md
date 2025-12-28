# クリーンアップ手順 / Cleanup Procedure

このドキュメントでは、Terraformで作成したすべてのAWSリソースを削除し、ローカルのkubectl設定をクリーンアップする手順について説明します。
This document explains the procedure to delete all AWS resources created by Terraform and clean up the local kubectl configuration.

---

## 1. AWSリソースの削除 / Deleting AWS Resources

以下のコマンドを実行して、Terraformが管理するすべてのAWSリソースを削除します。
Run the following command to delete all AWS resources managed by Terraform.

**注意:** この操作は元に戻せません。実行する前に、リソースが不要であることを再度確認してください。
**Warning:** This operation cannot be undone. Before proceeding, please double-check that the resources are no longer needed.

```bash
terraform destroy
```

プロンプトが表示されたら `yes` と入力して、削除を承認します。
When prompted, type `yes` to approve the deletion.

### (オプション) Terraform管理外のリソースの削除 / (Optional) Deleting Resources Not Managed by Terraform

もし`kubectl`を使って`LoadBalancer`タイプのサービスや`PersistentVolumeClaim`を手動で作成した場合、それらはTerraformの管理外となり`terraform destroy`では削除されません。クラスタを削除する前に、これらのリソースを手動で削除することをお勧めします。
If you have manually created resources such as `LoadBalancer` services or `PersistentVolumeClaims` using `kubectl`, they are not managed by Terraform and will not be deleted by `terraform destroy`. It is recommended to delete these resources manually before destroying the cluster.

```bash
# すべての名前空間でLoadBalancerタイプのサービスをリスト
# List LoadBalancer services in all namespaces
kubectl get services --all-namespaces | grep LoadBalancer

# 対象のサービスを削除
# Delete the target service
kubectl delete service <サービス名> -n <名前空間>
```

## 2. kubeconfigからコンテキストを削除 / Deleting Context from kubeconfig

AWSリソースを削除した後、ローカルの `~/.kube/config` ファイルからこのクラスタのコンテキスト設定を削除します。
After deleting the AWS resources, remove the cluster's context configuration from your local `~/.kube/config` file.

まず、以下のコマンドでコンテキスト名を確認します。クラスタ名を含むものが対象です。
First, identify the context name with the following command. Look for the one containing your cluster name.

```bash
kubectl config get-contexts
```

次に、対象のコンテキストを削除します。
Next, delete the target context.

```bash
kubectl config delete-context <コンテキスト名>
```

**実行例 / Example:**
```bash
# 以下はコンテキスト名の一例です。実際の値は上記の get-contexts コマンドで確認してください。
# The following is an example context name. Please use the actual value from the get-contexts command above.
kubectl config delete-context arn:aws:eks:ap-northeast-1:123456789012:cluster/my-eks-project-dev
```