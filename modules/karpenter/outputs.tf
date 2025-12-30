output "karpenter_node_instance_profile_name" {
  description = "The name of the IAM instance profile for Karpenter nodes."
  value       = aws_iam_instance_profile.karpenter_node_instance_profile.name
}

output "karpenter_controller_role_arn" {
  description = "The ARN of the IAM role for the Karpenter controller."
  value       = aws_iam_role.karpenter_controller_role.arn
}

output "karpenter_node_role_arn" {
  description = "The ARN of the IAM role for the Karpenter nodes."
  value       = aws_iam_role.karpenter_node_role.arn
}
