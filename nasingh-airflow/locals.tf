locals {
    environment = terraform.workspace
    aws_account = "<AWS account id>"
    bucket_name = "nasingh-airflow-${local.environment}"
    instance_name = "nasingh-airflow-${local.environment}"
    # backend args
    variables_prefix = "airflow/variables"
    connections_prefix = "airflow/connections"
}