# Demo Project:  
Complete CI/CD with Terraform  

## Technologies used:  
Terraform, Jenkins, Docker, AWS, Git, Java, Maven, Linux, Docker Hub  

## Project Description:  
Integrate provisioning stage into complete CI/CD Pipeline to automate provisioning server instead of deploying to an existing server  
- Create SSH Key Pair  
- Install Terraform inside Jenkins container  
- Add Terraform configuration to application’s git repository  
- Adjust Jenkinsfile to add “provision” step to the CI/CD pipeline that provisions EC2 instance  

So the complete CI/CD project we build has the following configuration:  
a. CI step: Build artifact for Java Maven application  
b. CI step: Build and push Docker image to Docker Hub  
c. CD step: Automatically provision EC2 instance using TF  
d. CD step: Deploy new application version on the provisioned EC2 instance with Docker Compose  

---

We’re gonna use `java-maven-app` project, feature branch: `jenkinsfile-sshagent`  
You can clone it from here: [https://github.com/gabidinica/java-maven-app](https://github.com/gabidinica/java-maven-app)  

And inside it add the folder `terraform`.  
Make sure you have a digital ocean droplet and on which you install Jenkins using docker.  

Get droplet it and port `8080` and paste it into the browser. Update the multi branch pipeline and configure then update the correct Git repository. In my case: [https://github.com/gabidinica/java-maven-app](https://github.com/gabidinica/java-maven-app)

## Create SSH Key-Pair

1. Go in AWS Console, EC2 -> Key Pairs -> Create Key Pair  
   - **Name:** myapp-key-pair  
   - **Private key file format:** .pem  
   - Click **Create Key Pair**  
   - The key file will be downloaded  

2. Go to Jenkins: `<droplet-ip>:8080`  
   - Navigate to `java-maven-app` -> **Credentials** -> **Create New Credentials**  
     - **Kind:** SSH Username with private key  
     - **ID:** server-ssh-key  
     - **Username:** ec2-user  
     - **Private Key:** In terminal, run `cat ~/Download/myapp-key-pair.pem` and copy the contents  
   - Paste the private key into Jenkins and click **Create**

---

## Install Terraform inside Jenkins

1. SSH into the droplet:  
```bash
ssh root@droplet_ip
```

2. Check running Docker containers: `docker ps`
3. Access Jenkins container as root: 
```bash
docker exec -it -u 0 container_id bash
```

4. Check the operating system: `cat /etc/os-release`
5. To install Terraform run:
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform

terraform -help
```

## Terraform Configuration Files

**Entry-script.sh**  
- Installs Docker and executes commands with sudo. Also installs Docker Compose.  

- In `Stage("deploy")`, we don’t know the public IP of the instance as it will be created by Terraform, so we will use the output command.  

- In `Stage("provisioner server")`, the result will be assigned to an environment variable in Jenkins: `EC2_PUBLIC_IP`.
- There was added also a sleep time to give server time to initialize and then execute the rest of the commands from deploy stage.  

- In `server-cmds.sh`, because of the execute commands we have to do `docker login`.  

- After committing changes to the branch and pushing changes, trigger the pipeline for `sshagent` branch.

### To Connect to Our Instance

1. Set permissions for the key:  
```bash
chmod 400 ~/downloads/myapp-key-pair.pem
```

2. Connect via SSH:
```bash
ssh -i ~/downloads/myapp-key-pair.pem ec2-user@ec2instance-ip
```

3. Check running Docker container: `docker ps`
