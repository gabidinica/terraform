# Demo Project: Modularize Project

## Technologies Used
- Terraform
- AWS
- Docker
- Linux
- Git

## Project Description
Divide Terraform resources into reusable modules.

---

### Adding New Modules

To add a new module:

1. Create a new folder called `modules`.
2. Inside `modules`, create folders for each module, e.g., `web_server` and `subnet`.

### Terminal Commands

1. Navigate to modules folder
cd modules

2. Create web_server module folder
mkdir web_server
cd web_server

3. Create Terraform files for web_server
touch main.tf
touch outputs.tf
touch variables.tf
touch providers.tf

4. Go back to modules folder
cd ..

5. Create subnet module folder
mkdir subnet
cd subnet

6. Create Terraform files for subnet
touch main.tf
touch outputs.tf
touch variables.tf
touch providers.tf

## Accessing Resources from a Child Module

To access resources from a child module, use the **outputs** defined in the child module's `outputs.tf`.

### Example

If you have a subnet module and want to use its subnet ID in an EC2 instance module:
```bash
subnet_id = module.myapp-subnet.subnet.id
```

> Here, myapp-subnet is the name of the child module, and subnet.id is the output defined in its outputs.tf.

- After creating the modules, run the following commands:
```bash
# Initialize Terraform
terraform init

# See the execution plan
terraform plan

# Apply the configuration automatically
terraform apply --auto-approve
```

### Verify Docker on EC2

1. SSH into your EC2 instance:
`ssh ec2-user@<public-ip-address>`

2. Check if Docker is running:
`docker ps`
