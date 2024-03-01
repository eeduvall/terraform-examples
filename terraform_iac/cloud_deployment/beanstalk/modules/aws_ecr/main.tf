resource "aws_ecr_repository" "ecr-be" {
  name                 = "express-be"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr-fe" {
  name                 = "react-fe"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# data "aws_iam_policy_document" "ecr_upload_policy" {
#   statement {
#     sid    = "ECR upload policy"
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["669387797487"]
#     }

#     actions = [
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:BatchGetImage",
#       "ecr:CompleteLayerUpload",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:InitiateLayerUpload",
#       "ecr:PutImage",
#       "ecr:UploadLayerPart"
#     ]
#   }
# }

# resource "aws_ecr_repository_policy" "ecr_policy" {
#   repository = aws_ecr_repository.ecr.name
#   policy     = data.aws_iam_policy_document.ecr_upload_policy.json
# }
