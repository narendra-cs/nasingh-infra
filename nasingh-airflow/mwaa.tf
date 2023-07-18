resource "aws_mwaa_environment" "airflow_env" {
    source_bucket_arn = aws_s3_bucket.airflow_bucket.arn
    dag_s3_path = "dags/"
    requirements_s3_path = "requirements.txt"
    execution_role_arn = aws_iam_role.airflow_role.arn
    name = "${local.instance_name}"
    environment_class = "mw1.small"
    airflow_version = "2.2.2"
    max_workers = 1
    min_workers = 1
    weekly_maintenance_window_start = "TUE:17:30"
    webserver_access_mode = "PUBLIC_ONLY"
    logging_configuration {
        dag_processing_logs {
        enabled   = true
        log_level = "WARNING"
        }

        scheduler_logs {
        enabled   = true
        log_level = "WARNING"
        }

        task_logs {
        enabled   = true
        log_level = "INFO"
        }

        webserver_logs {
        enabled   = true
        log_level = "WARNING"
        }

        worker_logs {
        enabled   = true
        log_level = "WARNING"
        }
    }
    network_configuration{
        security_group_ids = ["<sg_id>"]
        subnet_ids = ["<subnet-id-1>", "<subnet-id-2>"]
    }

    airflow_configuration_options = {
        "secrets.backend" = "airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend",
        "secrets.backend_kwargs" = "{\"variables_prefix\" : \"${local.variables_prefix}-${local.environment}\", \"connections_prefix\": \"${local.connections_prefix}-${local.environment}\"}"
    }

    tags = {
        // Mandatory Tags
        "Department"     = "Department Name"
        "Sub Department" = "Sub Department"
        "Product"        = "Product Name"
        "Creator"        = "terraform script"
        "Purpose"        = "nasingh-airflow instance"
        "Usage"          = "New"

        // Optional Tags
        "Service Name"     = "nasingh-airflow"
        "Repo Name"        = "nasingh-airflow"
        "Category"         = "${local.environment}"
        "Application Type" = "Workflow Management"
    }

   
    # Holding the MWAA deployment until it's role and source bucket are set up 
    depends_on = [
        aws_iam_role_policy_attachment.execution_policy_attach,
        aws_s3_bucket.airflow_bucket,
        aws_s3_bucket_object.requirements_file,
        aws_s3_bucket_object.dags_folder,
        aws_s3_bucket_versioning.enable_versioning,
        aws_s3_bucket_public_access_block.block_public_access
    ]
}