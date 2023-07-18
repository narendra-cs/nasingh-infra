# Role definition

resource "aws_iam_role" "airflow_role" {
  name = "nasingh-airflow-${local.environment}"
  assume_role_policy = data.aws_iam_policy_document.airflow_assume_role.json
}

data "aws_iam_policy_document" "airflow_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["airflow-env.amazonaws.com", "airflow.amazonaws.com"]
      type        = "Service"
    }
  }
}


# Policy attachments

resource "aws_iam_role_policy_attachment" "execution_policy_attach" {
  policy_arn = aws_iam_policy.execution_policy.arn
  role       = aws_iam_role.airflow_role.id
}

resource "aws_iam_role_policy_attachment" "read_secrets_policy_attach" {
  policy_arn = aws_iam_policy.read_secrets_policy.arn
  role       = aws_iam_role.airflow_role.id
}

resource "aws_iam_role_policy_attachment" "tfbrain_dag_policy_attach" {
  policy_arn = aws_iam_policy.tfbrain_dag_policy.arn
  role       = aws_iam_role.airflow_role.id
}

resource "aws_iam_role_policy_attachment" "ingestor_dag_policy_attach" {
  policy_arn = aws_iam_policy.ingestor_dag_policy.arn
  role       = aws_iam_role.airflow_role.id
}

resource "aws_iam_role_policy_attachment" "pricing_access_policy_attach" {
  policy_arn = aws_iam_policy.pricing_access_policy.arn
  role       = aws_iam_role.airflow_role.id
}

resource "aws_iam_role_policy_attachment" "emr_clustermonitor_dag_policy_attach" {
  policy_arn = aws_iam_policy.emr_clustermonitor_dag_policy.arn
  role       = aws_iam_role.airflow_role.id
}

# Policy meta definitions

resource "aws_iam_policy" "execution_policy" {
  name = "airflow-${local.environment}-execution-policy"
  policy = data.aws_iam_policy_document.execution_policy_doc.json
}

resource "aws_iam_policy" "read_secrets_policy" {
  name = "airflow-${local.environment}-read-secrets"
  policy = data.aws_iam_policy_document.read_secrets_policy_doc.json
}

resource "aws_iam_policy" "pricing_access_policy" {
  name = "airflow-${local.environment}-pricing-access"
  policy = data.aws_iam_policy_document.pricing_access_policy_doc.json
}

resource "aws_iam_policy" "emr_clustermonitor_dag_policy" {
  name = "airflow-${local.environment}-dag-emr-clustermonitor"
  policy = data.aws_iam_policy_document.emr_clustermonitor_dag_policy_doc.json
}

# Policy body definitions
data "aws_iam_policy_document" "execution_policy_doc" {
  version = "2023-02-17"

  statement {
    effect = "Allow"
    actions = ["airflow:PublishMetrics"]
    resources = ["arn:aws:airflow:us-east-1:${local.aws_account}:environment/${local.instance_name}"]
  }

  statement {
    effect = "Deny"
    actions = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::${local.bucket_name}", "arn:aws:s3:::${local.bucket_name}/*"]
  }

  statement {
    effect = "Allow"
    actions = ["s3:GetObject*", "s3:GetBucket*", "s3:List*"]
    resources = ["arn:aws:s3:::${local.bucket_name}", "arn:aws:s3:::${local.bucket_name}/*"]
  }

  statement {
    effect = "Allow"
    actions = ["logs:CreateLogStream", "logs:CreateLogGroup", "logs:PutLogEvents", "logs:GetLogEvents",      "logs:GetLogRecord",      "logs:GetLogGroupFields",      "logs:GetQueryResults"    ]
    resources = ["arn:aws:logs:us-east-1:${local.aws_account}:log-group:airflow-${local.instance_name}*"]
  }

  statement {
    effect = "Allow"
    actions = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["sqs:ChangeMessageVisibility", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = ["arn:aws:sqs:us-east-1:*:airflow-celery-*"]
  }

  statement {
    effect = "Allow"
    actions = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey*", "kms:Encrypt"]
    not_resources = ["arn:aws:kms:*:${local.aws_account}:key/*"]
    condition {
      test = "StringLike"
      variable = "kms:ViaService"
      values = ["sqs.us-east-1.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "read_secrets_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "AllowReadingOfSpecificSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = [
      "arn:aws:secretsmanager:us-east-1:${local.aws_account}:secret:airflow/variables-${local.environment}/*",
      "arn:aws:secretsmanager:us-east-1:${local.aws_account}:secret:airflow/connections-${local.environment}/*"
    ]
  }
}

data "aws_iam_policy_document" "pricing_access_policy_doc" {
  version = "2012-10-17"

  statement {
    sid     = "pricingaccess"
    effect  = "Allow"
    actions = ["pricing:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "emr_clustermonitor_dag_policy_doc" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = [
      "elasticmapreduce:GetManagedScalingPolicy",
      "elasticmapreduce:DescribeNotebookExecution",
      "elasticmapreduce:ListBootstrapActions",
      "elasticmapreduce:ListSteps",
      "elasticmapreduce:DescribeStudio",
      "elasticmapreduce:ListInstanceFleets",
      "elasticmapreduce:GetStudioSessionMapping",
      "elasticmapreduce:DescribeCluster",
      "elasticmapreduce:ListInstanceGroups",
      "elasticmapreduce:DescribeStep",
      "elasticmapreduce:ListInstances",
      "elasticmapreduce:DescribePersistentAppUI",
      "elasticmapreduce:DescribeEditor",
      "elasticmapreduce:GetAutoTerminationPolicy",
      "elasticmapreduce:ListWorkspaceAccessIdentities",
      "elasticmapreduce:DescribeJobFlows"
    ]
    resources = [
      "arn:aws:elasticmapreduce:*:${local.environment}:editor/*",
      "arn:aws:elasticmapreduce:*:${local.environment}:cluster/*",
      "arn:aws:elasticmapreduce:*:${local.environment}:studio/*",
      "arn:aws:elasticmapreduce:*:${local.environment}:notebook-execution/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "elasticmapreduce:DescribeSecurityConfiguration",
      "elasticmapreduce:DescribeReleaseLabel",
      "elasticmapreduce:GetBlockPublicAccessConfiguration",
      "elasticmapreduce:ViewEventsFromAllClustersInConsole",
      "elasticmapreduce:DescribeRepository",
      "elasticmapreduce:ListNotebookExecutions",
      "elasticmapreduce:ListRepositories",
      "elasticmapreduce:ListReleaseLabels",
      "elasticmapreduce:ListSecurityConfigurations",
      "elasticmapreduce:ListClusters",
      "elasticmapreduce:ListEditors",
      "elasticmapreduce:ListStudios",
      "elasticmapreduce:ListStudioSessionMappings"
    ]
    resources = ["*"]
  }
}
