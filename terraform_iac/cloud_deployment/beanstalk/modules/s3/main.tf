resource "aws_s3_bucket" "image_bucket" {
  bucket = "config-bucket"

  tags = {
    Name        = "Config Bucket"
    Service     = "Example"
  }
}