# 1
# Bucket + Static website hosting
resource "aws_s3_bucket" "static_site" {
  bucket = "choesuna-terraform-s3-bucket"
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Block Public Access 해제
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Bucket policy - PublicReadGetObject
data "aws_iam_policy_document" "public_read" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.static_site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [aws_s3_bucket_public_access_block.static_site]
}

# 2
# S3 Object - 프론트엔드 HTML 파일 업로드
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "index.html" # 실제 업로드할 HTML 파일의 경로로 수정해주세요. (예: "../1. Linux + HTTP + Node.js/assets/week1.html")
  content_type = "text/html"

  # 파일이 변경될 때마다 Terraform이 이를 감지하고 재업로드 하도록 etag 설정
  etag = filemd5("index.html") # source 파라미터와 동일한 경로로 지정해주세요.
}