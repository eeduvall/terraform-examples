resource "aws_iam_role" "ecr_role" {
  name = "ecr_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "build.apprunner.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "App Runner"
    Service = "Example"
  }
}

resource "aws_iam_role_policy_attachment" "policy_attachement" {
  role       = aws_iam_role.ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

output "iam_role_arn" {
  value = aws_iam_role.ecr_role.arn
}