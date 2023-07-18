# nasingh-airflow 

Github repo:  https://github.com/narendra-cs/nasingh-airflow

## Workspaces:
- *prod* - to deploy airflow prod infrastructure
- *dev* - to deploy airflow dev infrastructure
- *?* - any other name will deploy custom airflow instance with that name (so also *default* workspace will deploy airflow with *default* as a name)

## Steps to deploy:
1. Pick/create a workspace. :warning: <ins>**Make sure you are in the correct workspace**</ins> :warning: (Applying changes in the wrong workspace might break production!).
2. Define any <ins>airflow variables</ins> you want for your environment in `variables.tf`.
3. Verify that the changes you will make are the desired ones with `terraform plan`.
4. If yes do `terraform apply --auto-approve`. This will set up IAM roles, S3 bucket, secrets, and MWAA environment.
5. If you are setting up A new custom airflow environment. You will have to set up [resource-based policy](#setting-resource-based-policy) (see below). 
6. [Upload required files](#uploading-dags) into the bucket (either manually or using our CI/CD workflow).

### Setting resource based policy 
This terraform module provisions IAM roles and policies that are used by the airflow instance to get necessary secrets. Most of the secrets don't require additional permissions except one: `nasingh/airflow`. This secret contains a kube config encoded string and has a resource-based policy setup, defining which roles can access it. Because it's a resource-based policy, you have to manually add the role that has been created to the list of principals allowed to access that secret. If you need to do this follow these steps:
* Navigate to the secret in AWS web - [nasingh/airflow](https://us-east-1.console.aws.amazon.com/secretsmanager/secret?name=nasingh%2Fairflow&region=us-east-1)
* Click <ins>Edit permissions</ins> and append the arn of your new role as shown in the code snippet below

~~~json
{
  "Version" : "2012-10-17",
  "Statement" : [ 
    {
        "Effect" : "Allow",
        "Principal" : {
            "AWS" : "*"
        },
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "*",
        "Condition" : {
            "ArnEquals" : {
                "aws:PrincipalArn" : [ 
                    "ROLE 1", 
                    "ROLE 2",
                    ...
                    "<YOUR NEW ROLE ARN>"
                ]
            }
        }
    } 
  ]
}
~~~

> ℹ️ Q: Why is this resource policy set up like this? Can it not be simplified by pointing to ARN's directly in the `Principal` value?
>
>
>💬 A: Since we are using terraform to re-deploy our environemnts, our IAM roles will also get deleted and re-created over and over. This causes an issue for which the solution has been described [here](https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/#:~:text=What%20happens%20when%20a%20role%20in%20a%20trust%20policy%20is%20deleted) and requires such approach.


### Uploading dags 

The provisioned airflow instance is ready to use but empty. To upload the dags you can either find the dags and the code necessary to run them and upload it to the `dags/` folder or (more likely) use a CI/CD workflow following these steps:

* Find the [nasingh-airflow](https://github.com/MediaMath/nasingh-airflow) repo
* Navigate to `./circleci/config.yaml`
* Find the task responsible for aws deploy - `deploy-workflows-dev-aws`
* Change the bucket name in all of the commands to the s3 bucket connected to your environment
* Go to the bottom of the file where the workflow is defined and find/uncomment a part that runs the deploy workflows to aws task - `deploy-workflows-dev-aws` (Make sure you point to the right branch which is required to trigger the workflow)
* Commit the changes and that's it.