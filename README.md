# Terratest
 Deploy a rest API app to AWS and verify its functionality

**Prerequisites:**
1. AWS profile(s) and respective configuration(s) in ~/.aws.
How you've configured your AWS connectivity doesn't matter as long as you can create and destroy AWS resources via terraform.
**Setting up your Terratest environment**
1. After cloning the repository, fetch the go and Terratest dependencies with the included script 'sh setup_go.sh'
2. Execute 'terraform init' from /infrasture directory in order to initialze providers and modules. You'll need this before executing terratest.
3. The terraform in main.tf fetches and utilizes some of the modules defined in my Github repo github.com/borisveis/terraform_modules/
4. **Execute Terratest**
5. from root of repo, execute 'go test'

6. **What Terratest does**
Executes terraform in 'infrastructure/main.tf'
Deploys fast API app defined in app/app.py, In this case, a RESTfull application sho's GET response returns current milisecond time.
1. Retrieves some outputs from invoked terraform
2. Utilizes terraform outputs assigned to variables making assertions on their values.
3. Sends GET request to the public IP of deployed app and verifies treponse is a valid milisecond time
3. Finally: Terratest destroys all the resources it created regardless of the test(s) outcome.
Updates in branch: zero_down_time
terraform creates all necessary resources an deploys app/appy.py to an AWS instances with an exposed public IP.
**Alternative manual validation.**
1. execute the terraform i /infrastructure
2. upon successfull apply deployment, output `application_ip` returns the public ip of the deployed application.
Access the endpoint with
curl http://1.2.3.4:8000 , replacing 1.2.3.4 with the ip returned by terraform
The response should look like {"timestamp_ms":1745524089947}
