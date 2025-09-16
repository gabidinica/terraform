# Demo Project:
Terraform & AWS EKS

## Technologies used:
- Terraform
- AWS EKS
- Docker
- Linux
- Git

## Project Description:
Automate provisioning EKS cluster with Terraform

--- 

Because **CloudFormation** is only for AWS, we use the Terraform module **aws-vpc** to provision the VPC:  
👉 [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=inputs)

## Notes & Key Configurations

### 1. `single_nat_gateway = true`
- This means that all **private subnets** will route their outbound internet traffic through a **single NAT gateway**.  
- Helps reduce cost but can be a single point of failure.

### 2. Cloud Controller Manager (AWS)
- Responsible for orchestrating connections to **VPC, subnets, and other AWS resources**.  
- **Tags** are critical so the controller knows which resources (subnets, security groups, etc.) to interact with.

### 3. Kubernetes & Subnet Tagging
- Kubernetes must know **which subnets are public** so it can:
  - Create and provision **Load Balancers** in the **public subnets**.  
  - Ensure these Load Balancers are accessible from the internet.  
- Proper **tagging** of subnets is therefore **required** for successful provisioning.

## EKS Cluster Setup

We use the Terraform **EKS module**:  
👉 [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

- `cluster_version` specifies the **Kubernetes version** of the EKS cluster.  
- Example: `cluster_version = "1.29"`

---

## Worker Nodes (Node Groups)

- Worker nodes are provisioned using **managed node groups** within the EKS module.  
- Node groups define:
  - Instance type (e.g., `t2.small`)  
  - Desired capacity, min/max scaling  
  - AMI type 
- These node groups automatically join the EKS cluster once provisioned.

Since we added new modules, follow the Terraform workflow:

```bash
## Initialize providers and download modules
terraform init

## Preview resources to be created
terraform plan

## Apply changes (auto-approve skips confirmation prompt)
terraform apply --auto-approve
```

# Deploy nginx-app into our Cluster

## Prerequisites
- AWS CLI installed
- kubectl installed
- aws-iam-authenticator installed

> **Note:** In `eks-cluster.tf`, ensure public access is enabled:  
> ```hcl
> endpoint_public_access = true
> ```

Update the kubeconfig file so it has the correct **certificate, token, and IAM settings** for your cluster:

```bash
aws eks update-kubeconfig --name my-app-cluster --region eu-central-1
```

Check the worker nodes in the cluster: `kubectl get nodes`
Check existing pods: `kubectl get pods`
> Output: No resources (nothing deployed yet)

Apply the nginx configuration:
```bash
kubectl apply -f ~/Documents/terraform/nginx-config.yaml
```

Check again the pods: `kubectl get pods -w`

Check services to find the Load Balancer: `kubectl get svc`

### Access nginx

In the AWS Console, go to EC2 → Load Balancers.
> You should see 1 Load Balancer created for the nginx service.
- Click on the Load Balancer and copy its DNS name.
- Paste the DNS into a web browser → You should see *"Welcome to nginx!".*

## Cleanup

After testing, destroy all resources to avoid costs:
```bash
terraform destroy --auto-approve
```

