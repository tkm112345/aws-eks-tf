# Summary

* This repository is my learning for eks with terraform

## AWS Resources created by this Terraform configuration

This Terraform configuration will deploy an Amazon EKS cluster along with its networking and essential components.

### 1. Networking (VPC)

*   **VPC:** A new VPC is created using the `terraform-aws-modules/vpc/aws` module.
*   **Subnets:**
    *   **Public Subnets (3):** For resources requiring internet access, such as NAT Gateway.
    *   **Private Subnets (3):** For EKS worker nodes (EC2 instances).
*   **NAT Gateway:** One NAT Gateway will be created in a public subnet to allow private subnets to access the internet.
*   **Internet Gateway:** For VPC to internet communication.
*   **Route Tables:** Dedicated route tables for public and private subnets.
*   **Security Groups:** Basic security groups for EKS cluster communication and an additional one for EKS worker nodes.

### 2. EKS Cluster

*   **EKS Cluster (Control Plane):** An EKS cluster is deployed using the `terraform-aws-modules/eks/aws` module, managing the Kubernetes control plane.
*   **KMS Key:** An AWS KMS Key (and its alias) is created to encrypt Kubernetes Secret resources in the EKS cluster (if `enable_cluster_encryption` is true).
*   **IAM Roles:**
    *   EKS Cluster IAM Role: For the EKS control plane to interact with other AWS services.
    *   Node Group IAM Role: For worker nodes to interact with other AWS services.
*   **CloudWatch Logs:** A CloudWatch Log Group for EKS control plane logs (API, audit, etc.).

### 3. EKS Worker Nodes

*   **EKS Managed Node Group:** A group of EC2 instances acting as Kubernetes worker nodes.
    *   **Instance Type:** Configurable (default `t3.small`).
    *   **Scaling:** Minimum 1, desired 1, maximum 1 (configurable via `variables.tf`).
    *   **Disk Size:** 10GB per node (configurable).
    *   **User Data:** A pre-bootstrap script runs on node launch for initial setup.

### 4. EKS Addons

*   **VPC CNI:** Network plugin for Pod IP address management.
*   **CoreDNS:** In-cluster DNS resolution.
*   **Kube-Proxy:** Kubernetes network proxy.
*   **AWS EBS CSI Driver:** Allows dynamic provisioning and attachment of EBS volumes as persistent storage for Pods.

### 5. IAM Roles for Service Accounts (IRSA)

*   **IRSA for EBS CSI Driver:** IAM role allowing the EBS CSI Driver to manage EBS volumes.
*   **IRSA for AWS Load Balancer Controller (Optional):** IAM role for automatically creating and managing ALBs based on Kubernetes Ingress resources (currently disabled by default).
*   **IRSA for Cluster Autoscaler (Optional):** IAM role for automatic node scaling (currently disabled by default).

### How to Access the EKS Cluster

After `terraform apply` completes:

1.  **Ensure `kubectl` and `aws-cli` are installed** and configured with AWS credentials on your local machine.
2.  Run `terraform output configure_kubectl` to get the `aws eks update-kubeconfig` command.
3.  **Execute the displayed `aws eks update-kubeconfig` command** on your local terminal. This will configure your `~/.kube/config` file.
4.  Verify connection with `kubectl get nodes`.