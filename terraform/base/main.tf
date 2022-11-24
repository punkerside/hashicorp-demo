module "vpc" {
  source  = "punkerside/vpc/aws"
  version = "0.0.11"

  name = var.name == null ? random_string.this.result : var.name
}