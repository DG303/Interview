#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "eks-cluster" {
  name = "ha-interview-08-cluster"

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

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_security_group" "eks-cluster" {
  name        = "ha-interview-08"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-ha-interview-08"
  }
}

resource "aws_security_group_rule" "eks-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = var.private_subnets 
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
  ]
}

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
}


resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
}
