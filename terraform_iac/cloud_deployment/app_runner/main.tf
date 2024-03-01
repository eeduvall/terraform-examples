module "iam" {
  source = "./modules/iam"
}

module "vpc" {
  source = "./modules/vpc"
}

resource "aws_apprunner_vpc_connector" "be_connector" {
  vpc_connector_name = "app_runner_be_connector"
  subnets            = [module.vpc.vpc_private_subnet_id]
  security_groups    = [module.vpc.vpc_private_security_group_id]
}

resource "aws_apprunner_service" "App-BE" {
  service_name = "App-BE"

  #   observability_configuration {
  #     observability_configuration_arn = aws_apprunner_observability_configuration.example.arn
  #     observability_enabled           = true
  #   }

  source_configuration {
    authentication_configuration {
      access_role_arn = module.iam.iam_role_arn
    }

    image_repository {
      image_configuration {
        port = "3001"
      }
      image_identifier      = "669387797487.dkr.ecr.us-east-2.amazonaws.com/express-be:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  network_configuration {
    ingress_configuration {
      is_publicly_accessible = false
    }
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.be_connector.arn
    }
  }

  tags = {
    Name        = "App Runner - Express Backend"
    Service     = "App Runner"
    Environment = "Dev"
  }
}

resource "aws_apprunner_vpc_connector" "fe_connector" {
  vpc_connector_name = "app_runner_fe_connector"
  subnets            = [module.vpc.vpc_public_subnet_id]
  security_groups    = [module.vpc.vpc_public_security_group_id]
}

resource "aws_apprunner_service" "App-FE" {
  service_name = "A[[-FE"

  #   observability_configuration {
  #     observability_configuration_arn = aws_apprunner_observability_configuration.example.arn
  #     observability_enabled           = true
  #   }

  source_configuration {
    authentication_configuration {
      access_role_arn = module.iam.iam_role_arn
    }

    image_repository {
      image_configuration {
        port = "3000"
      }
      image_identifier      = "669387797487.dkr.ecr.us-east-2.amazonaws.com/react-fe:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  network_configuration {
    ingress_configuration {
      is_publicly_accessible = true
    }
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.fe_connector.arn
    }
  }

  tags = {
    Name        = "App Runner - React Frontend"
    Service     = "App Runner"
    Environment = "Dev"
  }
}

# resource "aws_apprunner_observability_configuration" "example" {
#   observability_configuration_name = "example"

#   trace_configuration {
#     vendor = "AWSXRAY"
#   }
# }
