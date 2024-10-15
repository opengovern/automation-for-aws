# Standard Operating Procedure (SOP)
## Setting Up AWS Organization for Integration with OpenGovernance

### Document Control
- **Version:** 1.0
- **Effective Date:** Oct 15, 2024
- **Author:** acx1729

---

### Table of Contents
1. [Purpose](#purpose)
2. [Scope](#scope)
3. [Prerequisites](#prerequisites)
4. [Procedure](#procedure)
    - 4.1. Clone the OpenGovernance Automation Repository
    - 4.2. Configure AWS CloudFormation Stack
    - 4.3. Generate IAM Access Credentials
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [References](#references)
8. [Appendix](#appendix)

---

### Purpose
This SOP provides a step-by-step guide for users of OpenGovernance to set up their AWS Organization. The setup facilitates the integration with OpenGovernance by configuring the AWS Organization’s Master and Child Accounts using provided CloudFormation templates and securing necessary IAM credentials.

### Scope
This procedure applies to AWS administrators responsible for managing the AWS Organization and integrating it with OpenGovernance. It covers cloning the necessary repository, deploying AWS resources via CloudFormation, and generating IAM credentials required for the integration.

### Prerequisites
Before commencing the setup, ensure the following prerequisites are met:

1. **AWS Account Access:**
   - Administrative privileges in the AWS Master Account.
   - Access to all Child Accounts within the AWS Organization.

2. **AWS CLI Configuration:**
   - Install the AWS CLI. [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
   - Configure the AWS CLI with appropriate credentials:
     ```sh
     aws configure
     ```
   
3. **Git Installation:**
   - Install Git on your local machine. [Git Downloads](https://git-scm.com/downloads)

4. **AWS CloudFormation Permissions:**
   - Permissions to create and manage CloudFormation stacks and necessary AWS resources, including IAM roles and policies.

5. **Repository Access:**
   - Ensure SSH access to GitHub repository `git@github.com:opengovern/automation-for-aws.git`. Set up SSH keys if not already configured.

### Procedure
Follow the steps below to set up your AWS Organization for integration with OpenGovernance.

#### 4.1. Clone the OpenGovernance Automation Repository

1. **Open Terminal/Command Prompt:**
   - Navigate to the directory where you want to clone the repository.

2. **Execute Git Clone Command:**
   ```sh
   git clone git@github.com:opengovern/automation-for-aws.git
   ```
   - This repository contains CloudFormation templates and automation scripts required to configure your AWS Organization's Master and Child Accounts.

3. **Navigate to the Cloned Repository:**
   ```sh
   cd automation-for-aws
   ```

#### 4.2. Configure AWS CloudFormation Stack

1. **Identify Your Root Organization ID:**
   - You can find the Root Organization ID in the AWS Organizations console under the **"Details"** section.

2. **Run the CloudFormation Create-Stack Command:**
   ```sh
   aws cloudformation create-stack \
     --stack-name OpenGovernance-Deploy \
     --template-body file://./AWSOrganizationDeployment.yml \
     --capabilities CAPABILITY_NAMED_IAM \
     --parameters ParameterKey=OrganizationUnitList,ParameterValue=<ROOT_ORG_ID>
   ```
   - **Parameters Explanation:**
     - `--stack-name`: Name of the CloudFormation stack. Here, it is set to `OpenGovernance-Deploy`.
     - `--template-body`: Path to the CloudFormation template file. Ensure the path is correct (`./AWSOrganizationDeployment.yml`).
     - `--capabilities`: Acknowledge that the stack may create IAM resources with custom names.
     - `--parameters`: Passes parameters to the template. Replace `<ROOT_ORG_ID>` with your actual Root Organization ID.

3. **Monitor Stack Deployment:**
   - Use the AWS Management Console or AWS CLI to monitor the progress of the stack deployment.
   - **Using AWS CLI:**
     ```sh
     aws cloudformation describe-stacks --stack-name OpenGovernance-Deploy
     ```
   - Wait until the stack status is `CREATE_COMPLETE`.

#### 4.3. Generate IAM Access Credentials

1. **Access the IAM Console:**
   - Navigate to the [AWS IAM Console](https://console.aws.amazon.com/iam/).

2. **Create/Open `OpenGovernanceIAMUser`:**
   - If the user `OpenGovernanceIAMUser` does not exist, create a new IAM user with this name.
   - Assign necessary permissions as per OpenGovernance requirements.

3. **Generate Access Key:**
   - Select the `OpenGovernanceIAMUser`.
   - Navigate to the **"Security credentials"** tab.
   - Click on **"Create access key"**.
   - **Important:** 
     - Copy the **Access Key ID** and **Secret Access Key** immediately. You will not be able to view the secret key again.
     - Store these credentials securely, as they are required for the OpenGovernance integration.

4. **Finalize IAM User Setup:**
   - Ensure that the `OpenGovernanceIAMUser` has the appropriate permissions and policies attached to interact with the deployed resources.

### Verification
After completing the setup, perform the following verification steps to ensure successful integration:

1. **CloudFormation Stack Verification:**
   - Confirm that the `OpenGovernance-Deploy` stack is in the `CREATE_COMPLETE` status.
   - Verify that all resources (Master and Child Accounts configurations) are deployed as expected.

2. **IAM Credentials Verification:**
   - Test the IAM access key and secret by configuring the AWS CLI with these credentials and performing a simple AWS CLI command, such as listing S3 buckets:
     ```sh
     aws s3 ls --access-key <AccessKeyID> --secret-key <SecretAccessKey>
     ```
   - Replace `<AccessKeyID>` and `<SecretAccessKey>` with the actual credentials.

3. **OpenGovernance Integration Check:**
   - Follow any additional steps provided by OpenGovernance to complete the integration.
   - Log into the OpenGovernance dashboard or interface to confirm that the AWS Organization is recognized and properly integrated.

### Troubleshooting

- **CloudFormation Stack Fails to Create:**
  - **Check Template Syntax:** Ensure that the `AWSOrganizationDeployment.yml` file is correctly formatted and free of syntax errors.
  - **Verify Permissions:** Confirm that the AWS CLI user has sufficient permissions to create the stack and associated resources.
  - **Resource Limits:** Check AWS service limits to ensure that creating new resources won't exceed existing quotas.
  - **Review Stack Events:** Use the AWS Management Console or CLI to inspect stack events for detailed error messages.
    ```sh
    aws cloudformation describe-stack-events --stack-name OpenGovernance-Deploy
    ```

- **SSH Authentication Issues While Cloning Repository:**
  - **SSH Key Configuration:** Ensure that your SSH keys are correctly configured and added to your GitHub account.
  - **Repository Access Permissions:** Verify that your GitHub user has access rights to the `opengovern/automation-for-aws` repository.

- **IAM Access Key Issues:**
  - **Credential Accuracy:** Double-check that the Access Key ID and Secret Access Key are entered correctly.
  - **User Permissions:** Ensure that the `OpenGovernanceIAMUser` has the necessary permissions to perform required actions.

- **General Connectivity Issues:**
  - **Network Configuration:** Ensure that your network allows outbound connections to AWS services.
  - **AWS Service Status:** Check the [AWS Service Health Dashboard](https://status.aws.amazon.com/) for any ongoing issues.

### References
- [AWS Organizations Documentation](https://docs.aws.amazon.com/organizations/index.html)
- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
- [AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/)