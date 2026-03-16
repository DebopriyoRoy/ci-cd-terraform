# Terraform CI/CD Infrastructure

Provisions AWS infrastructure via Jenkins. Three modules, all wired together.

## Resources created

| Module | Resource | Name in AWS |
|--------|----------|-------------|
| `vpc`  | VPC | `crt-from-jenkins` |
| `vpc`  | Public subnets | `crt-from-jenkins-subnet-public1-us-east-1a` / `...-1b` |
| `vpc`  | Private subnets | `crt-from-jenkins-subnet-private1-us-east-1a` / `...-1b` |
| `vpc`  | Internet Gateway | `crt-from-jenkins-igw` |
| `vpc`  | Public route table | `crt-from-jenkins-rtb-public` |
| `vpc`  | Private route tables | `crt-from-jenkins-rtb-<subnet-name>` × 2 |
| `vpc`  | S3 VPC endpoint | `crt-from-jenkins-vpce-s3` |
| `vpc`  | Security group | `crt-from-jenkins-ec2-sg` |
| `iam`  | IAM role + instance profile | `ec2-from-jenkins` |
| `ec2`  | EC2 instance | `crtd-from-jenkins` |

## Prerequisites

1. Store AWS credentials in Jenkins as two **Secret text** credentials:
   - ID: `aws-access-key-id`
   - ID: `aws-secret-access-key`

2. Update your Jenkinsfile to export them correctly:
   ```groovy
   environment {
     AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
     AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
   }
   ```

## Jenkins pipeline

```groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [],
                  userRemoteConfigs: [[url: 'https://github.com/DebopriyoRoy/ci-cd-terraform.git']])
            }
        }
        stage('Init')  { steps { sh 'terraform init'  } }
        stage('Plan')  { steps { sh 'terraform plan'  } }
        stage('Apply') { steps { sh 'terraform apply -auto-approve' } }
    }
}
```

## Resource map (matches AWS console)

```
VPC                    Subnets (4)                          Route tables (4)              Network Connections (2)
crt-from-jenkins  →   us-east-1a:                      →   crt-from-jenkins-rtb-public   crt-from-jenkins-igw
                         public1-us-east-1a                 crt-from-jenkins-rtb-private1  crt-from-jenkins-vpce-s3
                         private1-us-east-1a                crt-from-jenkins-rtb-private2
                       us-east-1b:
                         public2-us-east-1b
                         private2-us-east-1b
```
