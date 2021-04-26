data "aws_vpc" "selected" {
  tags = {
    Environment = "EKS"
    Name        = "metricstream"
    Terraform   = "true"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Environment = "EKS"
    Name        = "metricstream"
    Terraform   = "true"
  }
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnet_ids.selected.ids)
  id    = tolist(data.aws_subnet_ids.selected.ids)[count.index]
}
