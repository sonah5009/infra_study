# Frontend static site bucket (created once, then managed via state)
resource "aws_s3_bucket" "static_site" {
  bucket = var.frontend_bucket_name
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
# index.html 업로드 (S3 Object)
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_site.id
  key    = "index.html"
  # 로컬 파일을 S3로 업로드
  source = "${path.module}/index.html"
  # 브라우저에서 HTML로 열리도록
  content_type = "text/html; charset=utf-8"
  # 파일 내용이 바뀌면 Terraform이 변경을 감지하도록
  etag = filemd5("${path.module}/index.html")

  depends_on = [aws_s3_bucket_policy.public_read]
}

resource "aws_s3_object" "assets" {
  for_each = fileset("${path.module}/assets", "**")

  bucket       = aws_s3_bucket.static_site.id
  key          = "assets/${each.value}"
  source       = "${path.module}/assets/${each.value}"
  content_type = endswith(each.value, ".html") ? "text/html; charset=utf-8" : "application/octet-stream"
  etag         = filemd5("${path.module}/assets/${each.value}")

  depends_on = [aws_s3_bucket_policy.public_read]
}
