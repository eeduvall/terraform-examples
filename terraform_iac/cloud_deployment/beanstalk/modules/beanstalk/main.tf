module "s3_container_images" {
  source = "./modules/s3"
}

resource "aws_iam_role" "beanstalk_role" {
  name = "beanstalk_sts_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "BeanstalkRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    service = "Example"
  }
}

resource "aws_iam_role_policy_attachment" "web_tier" {
  role       = aws_iam_role.beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "multicontainer_docker" {
  role       = aws_iam_role.beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "worker_tier" {
  role       = aws_iam_role.beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_instance_profile" "beanstalk_iam_instance_profile" {
  name = "beanstalk_iam_instance_profile"
  role = aws_iam_role.beanstalk_role.name
}

resource "aws_iam_policy" "beanstalk_ecr_policy" {
  name = "beanstalk_ecr_policy"
  # role = aws_iam_role.beanstalk_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "AllowPull",
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ],
        "Resource" = ["arn:aws:ecr:us-east-2:669387797487:repository/express-be", "arn:aws:ecr:us-east-2:669387797487:repository/react-fe"]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.beanstalk_role.name
  policy_arn = aws_iam_policy.beanstalk_ecr_policy.arn
}

resource "aws_iam_instance_profile" "iam_beanstalk_instance_profile" {
  name = "BeanstalkProfile"
  role = aws_iam_role.beanstalk_role.name
}

resource "aws_elastic_beanstalk_application" "beanstalk" {
  name        = "Beanstalk"
  description = "FE and BE"

  tags = {
    Name        = "Beanstalk"
    Service     = "Example"
    Environment = "Latest"
  }
}

# resource "aws_elastic_beanstalk_environment" "beanstalk-env" {
#   name                = "beanstalk-env"
#   application         = aws_elastic_beanstalk_application.example.name
#   solution_stack_name = "64bit Amazon Linux 2023 v4.0.0 running ECS"
#   tier = "WebServer"
#   # version_label = aws_elastic_beanstalk_application.example.name

#   # want launch template
#   setting {
#       namespace = "aws:autoscaling:launchconfiguration"
#       name = "IamInstanceProfile"
#       value = aws_iam_instance_profile.iam_beanstalk_instance_profile.name
#   }

#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name = "InstanceType"
#     value = "t2.micro"
#   }

#   setting {
#     name      = "IamInstanceProfile"
#     namespace = "aws:autoscaling:launchconfiguration"
#     value     = aws_iam_instance_profile.iam_beanstalk_instance_profile.arn
#   }

#   tags = {
#     Name        = "Beanstalk Env"
#     Service     = "Example"
#     Environment = "Latest"
#   }
# }

locals {
  app_env = {
    DEV = "dev"
  }
}

resource "random_pet" "ebs_bucket_name" {}

resource "aws_s3_bucket" "ebs" {
  bucket = "${random_pet.ebs_bucket_name.id}"
}

resource "aws_s3_object" "ebs_deployment" {
  bucket     = aws_s3_bucket.ebs.id
  key        = "Dockerrun.aws.json"
  source     = "${path.module}/Dockerrun.aws.json"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                   = "BeanstalkEnv"
  application            = aws_elastic_beanstalk_application.beanstalk.name
  version_label          = aws_elastic_beanstalk_application_version.app_version.name
  solution_stack_name    = "64bit Amazon Linux 2023 v4.0.0 running ECS"#"64bit Amazon Linux 2023 v4.1.0 running Docker"
  tier                   = "WebServer"
  wait_for_ready_timeout = "10m"

  setting {
    name      = "InstancePort"
    namespace = "aws:cloudformation:template:parameter"
    value     = 3000
  }

  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_instance_profile.iam_beanstalk_instance_profile.name
  }

  setting {
    name      = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "t2.small"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "True"
  }

  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value = join(",", [
      # additional security groups. e.g. database security group, etc.
    ])
  }


#   setting {
#     name      = "VPCId"
#     namespace = "aws:ec2:vpc"
#     value     = var.vpc_id
#   }

#   setting {
#     name      = "Subnets"
#     namespace = "aws:ec2:vpc"
#     value     = join(",", var.public_subnet_ids)
#   }

#   setting {
#     name      = "SSLCertificateId"
#     namespace = "aws:elb:loadbalancer"
#     value     = aws_acm_certificate.cert.certificate_id
#   }

  dynamic "setting" {
    for_each = local.app_env
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "beanstalk-app-version"
  application = aws_elastic_beanstalk_application.beanstalk.name
  bucket      = aws_s3_bucket.ebs.id
  key         = aws_s3_object.ebs_deployment.id
}