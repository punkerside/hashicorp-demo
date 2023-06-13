data "aws_ami" "main" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.name}-*"]
  }
}

data "aws_vpc" "main" {
  tags = {
    Name = var.name
  }
}