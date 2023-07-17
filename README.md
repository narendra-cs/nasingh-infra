# nasingh-infra
A repository for storing all terraform scripts.

## Working in this repo
1. create a new branch
2. `cd` into the sub-directory of interest
3. `terraform init`
    - you might need to update *required_version* in provider.tf to match your terraform version
4. `terraform workspace list` to see all the workspaces.
    - you may need to run `terraform workspace new dev` if *dev* workspace hasn't been created for testing
5. `terraform workspace select <workspace>` to pick a workspace to use - if a `dev` workspace exists, select that one first.
6. make changes
7. `terraform plan` to see the changes
   1. you may need to update various versions at this point via `brew <upgrade/install> terraform`
   2. set the provider version in `provider.tf` to whatever the latest terraform you just installed
   3. `terraform init -update`
8. `terraform apply --auto-approve` to apply the changes you just saw
9. manually validate that whatever changes you made had the desired effect
10. select the `prod` workspace. If it isn't specified then `default` is prod. Apply the same changes to prod.
11. commit and PR your branch against master

## Adding external resources
follow the same procedure as detailed above, except that when you are working in a workspace step 5 becomes
5a. create a resource that matches the infrastructure that you want to import
5b. run `terraform import <resource_type>.<resource_name>`
Not that you will likely have to create "dev" versions of the same resources for the different workspaces since what
you are importing here will probably be the "prod" infra.

## Guidelines
* Each sub-directory should map to the git repo name of the project that the terraform corresponds to.
    *  If there is no corresponding repo, then please use a descriptive name such that a fresh SRE can look at it and know the contents without reading everything.
* All terraform provider.tf files must specify versions of terraform and plugins.
* Terraform state files should *NOT* be included in the repository itself - it should be in appropriate s3 buckets.

## Terraform required_version

It is ok to update the **terraform.required_version** to the latest Terraform client.

For example, you might install/upgrade to your Terraform client which might be newer than the one specified in the repo, and you could update the version in repo to match yours. As a consequence, others in your team would need to grade their client version as well. This is a design choice.

* Download or update Terraform
    * https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started
* AWS provider version list
    * https://registry.terraform.io/providers/hashicorp/aws/latest

### Terraform command

```
Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Experimental support for module integration testing
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.
```

## AWS access setup

If you have issue to access AWS, try to follow the following

1. unset AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env variables if there are any
2. set up your `~/.aws/config` like this

```
[default]
role_arn = <role ARN>
source_profile = me
region = <Default AWS Region to use>
role_session_name = user_session

[profile me]
aws_access_key_id = YOUR_AWS_ACCESS_KEY_ID
aws_secret_access_key = YOUR_AWS_SECRET_ACCESS_KEY
region = <Default AWS Region to use>
output = json
```

where YOUR_AWS_ACCESS_KEY_ID and YOUR_AWS_SECRET_ACCESS_KEY should be updated to your credentials

## S3 Bucket Management

Please follow standard S3 Bucket Strategies
