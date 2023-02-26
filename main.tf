resource "aws_s3_bucket" "this" {
  bucket = "${var.application_name}-logging-${random_id.this.hex}"
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.this.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  topic {
    topic_arn = aws_sns_topic.this.arn
    events = [
    "s3:ObjectRemoved:*"]
  }
}

resource "aws_sns_topic" "this" {
  name = "${var.application_name}-logging-topic-${random_id.this.hex}"
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}


data "aws_iam_policy_document" "this" {
  statement {
    sid    = "TopicPubishFromS3"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
      "s3.amazonaws.com"]
    }
    actions = [
      "SNS:Publish"
    ]
    resources = [
    aws_sns_topic.this.arn]

    condition {
      test     = "ForAnyValue:ArnEquals"
      variable = "aws:SourceArn"
      values = [
      aws_s3_bucket.this.arn]
    }
  }
}