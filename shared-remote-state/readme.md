# Demo Project: Configure a Shared Remote State

## Technologies Used
- Terraform
- AWS S3

## Project Description
Configure Amazon S3 as remote storage for Terraform state.

----

The code can be found under this branch: [jenkinsfile-sshagent](https://github.com/gabidinica/java-maven-app/tree/jenkinsfile-sshagent)  
We’re using the `java-maven-app` repository.  

Before making any changes, ensure the environment is clean by destroying any existing infrastructure:

```bash
terraform destroy --auto-approve
```

In the `main.tf` file, configure the remote state as follows:

```hcl
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "myapp-tf-s3-bucket"
    key    = "myapp/state.tfstate"
    region = "eu-central-1"
  }
}
```

- The backend is the remote backend for Terraform. S3 is mostly used to store files in buckets.  
- We will create a bucket named `myapp-tf-s3-new-bucket`, which should be uniquely named across AWS.

## Create AWS S3 Bucket

1. In the AWS Console, search for **S3**.
2. Click on **Create Bucket**.
3. Set the **Bucket name**: `app-tf-s3-new-bucket` (must be unique).
4. Enable **Bucket versioning**.
5. Set **Default encryption** → **Bucket key**: Disable.
6. Click on **Create bucket**.

## Execute Jenkins Pipeline

1. Go to **Jenkins**.
2. Select and build the **sshagent** pipeline.
3. Check the **build logs** to verify execution and troubleshoot if needed.

## Verify Terraform State in S3

1. Go to the **AWS Console** and open **S3**.
2. Navigate to your bucket (`myapp-tf-s3-new-bucket`).
3. Refresh the bucket view.
4. Check that the object `state.tfstate` is present.

## Access Current Terraform State from AWS

On your local machine, open a terminal and run:

```bash
terraform init
terraform state list
```
