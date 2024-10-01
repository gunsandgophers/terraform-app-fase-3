resource "aws_security_group" "sg" {
  name        = "SG-${local.aws_project_name}"
  description = "Usado no EKS com 6/7SOAT"
  vpc_id      = data.aws_vpc.vpc.id

}
