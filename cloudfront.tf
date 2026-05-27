data "aws_lb" "api_alb" {
  name = "project-alb-seoul"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  comment             = "S3(website) + ALB routing"
  default_root_object = "index.html"

  # =========================
  # Origin #1: S3 Website Endpoint
  # =========================
  origin {
    origin_id   = "s3-website"
    domain_name = aws_s3_bucket_website_configuration.static_site.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # S3 website endpoint는 보통 http
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # =========================
  # Origin #2: ALB
  # =========================
  origin {
    origin_id   = "alb-api"
    domain_name = data.aws_lb.api_alb.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # ALB에 HTTPS 리스너가 있으면 https-only로 바꿔도 됨
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # =========================
  # Default behavior (프론트)
  # =========================
  default_cache_behavior {
    target_origin_id       = "s3-website"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  # =========================
  # Ordered behavior (API: /api/*)
  # =========================
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "alb-api"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
  }

  # 기본 인증서(CloudFront 도메인)로 HTTPS 사용
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # 지역 제한 없음
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}