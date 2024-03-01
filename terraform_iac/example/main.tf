provider "aws" {
  region = var.region
}

# resource "aws_db_instance" "my_database" {
#   allocated_storage       = 5
#   storage_type            = "gp2"
#   engine                  = "postgres"
#   engine_version          = "15.4"
#   instance_class          = "db.t4g.micro"
#   db_name                 = var.db_name
#   username                = var.db_username
#   password                = var.db_password
# #   parameter_group_name    = "default.postgres12"
#   backup_retention_period = 0
# }

resource "aws_iam_role" "beanstalk_service" {
  name = "beanstalk_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "beanstalk_log_attach" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "beanstalk_iam_instance_profile" {
  name = "beanstalk_iam_instance_profile-example"
  role = aws_iam_role.beanstalk_service.name
}

resource "aws_s3_bucket" "my_app_ebs" {
  bucket = "my-app-ebs-example"
  acl    = "private"

  tags = {
    Name = "My APP EBS"
  }
}

resource "aws_s3_bucket_object" "my_app_deployment" {
  bucket = aws_s3_bucket.my_app_ebs.id
  key    = "Dockerrun.aws.json"
  source = "Dockerrun.aws.json"
}

resource "aws_elastic_beanstalk_application" "my_app" {
  name        = "my-app-dev"
  description = "My wonderful app"
}

resource "aws_elastic_beanstalk_environment" "dev_env" {
  name         = "my-app-dev-env"
  application  = aws_elastic_beanstalk_application.my_app.name
  cname_prefix = "my-app"

  solution_stack_name = "64bit Amazon Linux 2 v3.6.3 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_iam_instance_profile.arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "True"
  }


  dynamic "setting" {
    for_each = local.app_env
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }



}

resource "aws_elastic_beanstalk_application_version" "my_app_ebs_version" {
  name        = "my-app-ebs-version"
  application = aws_elastic_beanstalk_application.my_app.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.my_app_ebs.id
  key         = aws_s3_bucket_object.my_app_deployment.id
}