### IAM ROLE ###
resource "aws_iam_role" "metricstream" {
  name = "metricstream"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "metricstream-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.metricstream.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "metricstream-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.metricstream.name
}

###  EKS CLUSTER ###
resource "aws_eks_cluster" "metricstream" {
  name     = "metricstream"
  role_arn = aws_iam_role.metricstream.arn

  vpc_config {
    subnet_ids = data.aws_subnet_ids.selected.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.metricstream-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.metricstream-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.metricstream.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.metricstream.certificate_authority[0].data
}
