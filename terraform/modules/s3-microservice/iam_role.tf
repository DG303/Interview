resource "aws_iam_role" "s3_microservice" {
  name = "s3_microservice"
  #assume_role_policy =  templatefile("oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "s3-microservice", SA_NAME = "s3-microservice" })
  assume_role_policy =  templatefile("oidc_assume_role_policy.json", { OIDC_ARN = "arn:aws:iam::291907804730:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/CA8F7B592FC98F418E28C2C320575C0F", OIDC_URL = "oidc.eks.us-east-1.amazonaws.com/id/CA8F7B592FC98F418E28C2C320575C0F", NAMESPACE = "s3-microservice", SA_NAME = "s3-microservice" })
  tags = {
      "ServiceAccountName"      = "s3-microservice"
      "ServiceAccountNameSpace" = "s3-microservice"
    }

}

resource "aws_iam_role_policy_attachment" "s3_microservice" {
  role       = aws_iam_role.s3_microservice.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" 
  depends_on = [aws_iam_role.s3_microservice]
}
