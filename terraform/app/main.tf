resource "aws_iam_role" "main" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = var.name
  }
}

resource "aws_iam_instance_profile" "main" {
  name = var.name
  role = aws_iam_role.main.name
}

resource "aws_security_group" "main" {
  name        = var.name
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

resource "aws_launch_template" "main" {
  name                   = var.name
  ebs_optimized          = true
  image_id               = data.aws_ami.main.id
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.main.id]

  iam_instance_profile {
    name = var.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.name
    }
  }

  tag_specifications {
    resource_type = "spot-instances-request"

    tags = {
      Name = var.name
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = var.name
    }
  }
}