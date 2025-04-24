provider "aws" {
  region = "us-west-1"
}

# --- IAM Role for CodeBuild ---
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "CodeBuildPolicy"
  description = "Policy for CodeBuild Project"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*",
          "logs:*",
          "codebuild:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_role_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

# --- S3 Module ---
module "s3" {
  source      = "git@github.com:borisveis/terraform_modules.git//aws/s3"
  bucket_name = "teratest-test"
}

# --- CodeBuild Module ---
module "codebuild" {
  source           = "github.com/borisveis/terraform_modules//aws/codebuild?ref=main"
  name             = "terratest_learn"
  source_location  = "https://github.com/borisveis/LLMTesting.git"
  codebuild_image  = "aws/codebuild/standard:4.0"
  service_role_arn = aws_iam_role.codebuild_role.arn
  artifact_type    = "NO_ARTIFACTS"
}

# --- Get Default VPC & Subnet ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# --- FastAPI App Module (your EC2 app) ---
module "app_under_test" {
  source                       = "./tf_app"
  local_app_path               = "../app"
  instance_type                = "t2.micro"
  ami_id                       = "ami-02fd5efc30e766ac2"
  associate_public_ip_address  = true
  key_name                     = "fastapiapp"
  subnet_id                    = data.aws_subnets.default.ids[0]
  private_key_path             = "${path.module}/../../fastapiapp.pem"
}

# --- Outputs ---
output "bucket_arn" {
  value = module.s3.bucket_arn
}

output "codebuild_arn" {
  value = module.codebuild.codebuild_arn
}

output "application_ip" {
  value = module.app_under_test.app_public_ip
}
