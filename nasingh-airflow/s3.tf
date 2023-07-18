resource "aws_s3_bucket" "airflow_bucket" {
  bucket = "${local.bucket_name}"

  # Allows to delete the bucket with versioning enabled withour error 
  force_destroy = true

  tags = {
    // Mandatory Tags
    "Department"     = "Department Name"
    "Sub Department" = "Sub Department"
    "Product"        = "Product Name"
    "Creator"        = "terraform script"
    "Purpose"        = "Store nasingh-airflow instance files"
    "Usage"          = "New"

    // Optional Tags
    "Service Name"     = "nasingh-airflow"
    "Repo Name"        = "nasingh-airflow"
    "Category"         = "${local.environment}"
    "Application Type" = "Workflow Management"
  }
}

resource "aws_s3_bucket_versioning" "enable_versioning" {
  # Enable Versioning
  bucket = aws_s3_bucket.airflow_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.airflow_bucket.id

  # Block all public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "requirements_file" {
  bucket = aws_s3_bucket.airflow_bucket.id
  key    = "requirements.txt"
  source = "./requirements.txt"
}

resource "aws_s3_bucket_object" "dags_folder" {
  bucket = aws_s3_bucket.airflow_bucket.id
  key    = "dags/"
  source = "/dev/null"
}