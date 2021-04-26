output "role_arn" {
  value = aws_iam_role.eks-cluster.arn
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "cert_auth" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}
