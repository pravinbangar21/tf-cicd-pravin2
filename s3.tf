resource "aws_s3_bucket" "pipeline-artifacts" {
  bucket = "my-code-pipeline-artifacts-p21"
  acl = "private"
}
