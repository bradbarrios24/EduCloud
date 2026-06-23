# ============================================
# MÓDULO: CloudFront con S3 Origin
# ============================================

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  default_root_object = var.default_root_object
  web_acl_id          = var.web_acl_id

  dynamic "logging_config" {
    for_each = var.enable_logging && var.log_bucket_name != "" ? [1] : []
    content {
      include_cookies = false
      bucket          = var.log_bucket_name
      prefix          = "cloudfront-logs/"
    }
  }

origin {
  domain_name = var.s3_bucket_domain_name
  origin_id   = var.origin_id

  # QUITAR s3_origin_config con OAI
  # Usar origin_access_control en su lugar (OAC, más moderno)
  origin_access_control_id = aws_cloudfront_origin_access_control.this.id
}


  default_cache_behavior {
    target_origin_id = var.origin_id

    allowed_methods = var.allowed_methods
    cached_methods  = var.cached_methods

    forwarded_values {
      query_string = var.forward_query_string
      cookies {
        forward = var.cookie_forward
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type == "none" ? "none" : var.geo_restriction_type
      locations        = var.geo_restriction_type == "none" ? [] : var.geo_allowed_locations
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != null ? [1] : []
    content {
      acm_certificate_arn      = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  tags = var.tags
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "oac-${var.origin_id}"
  description                       = "OAC para S3 frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_caller_identity" "current" {}