resource "aws_iam_role" "main" {
  name = var.name == null ? random_string.this.result : var.name

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
    Name = var.name == null ? random_string.this.result : var.name
  }
}


# resource "aws_launch_template" "main" {
#   name = null ? random_string.this.result : var.name
#   ebs_optimized = true
#   image_id = "ami-test"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = ["sg-12345678"]

#   iam_instance_profile {
#     name = null ? random_string.this.result : var.name
#   }

#   block_device_mappings {
#     device_name = "/dev/sda1"

#     ebs {
#       volume_size = 20
#     }
#   }

#   monitoring {
#     enabled = true
#   }

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = var.name == null ? random_string.this.result : var.name
#     }
#   }

#   tag_specifications {
#     resource_type = "volume"

#     tags = {
#       Name = var.name == null ? random_string.this.result : var.name
#     }
#   }
# }