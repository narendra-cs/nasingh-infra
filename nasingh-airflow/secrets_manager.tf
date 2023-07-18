resource "aws_secretsmanager_secret" "airflow_variable_definition" {

    # select variables from the current environment
    for_each = lookup(var.airflow_vars,local.environment,var.airflow_vars["empty"])

    # Allows to re-apply the terraform provisioning. Avoids the "already exists" error for secrets which would be in their recovery window period.
    # Not applied when chosen environment is "prod"
    recovery_window_in_days = local.environment == "prod" ? 30 : 0 

    name = "${local.variables_prefix}-${local.environment}/${each.key}"
    description = "${each.key}"
}

resource "aws_secretsmanager_secret_version" "airflow_variable_value" {
    for_each = aws_secretsmanager_secret.airflow_variable_definition
    secret_id = each.value.id
    secret_string = lookup(lookup(var.airflow_vars,local.environment,var.airflow_vars["empty"]), each.value.description, null)
}