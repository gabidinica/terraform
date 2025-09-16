module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.2.0"
  
  name = "myapp-eks-cluster"
  kubernetes_version = "1.30"
  endpoint_public_access = true


   subnet_ids = module.myapp-vpc.private_subnets
   vpc_id = module.myapp-vpc.vpc_id

   tags = {
    environment = "development"
    application = "myapp"
   }

     eks_managed_node_groups = {
    dev = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 3
    }
  }
}