# Terratest
 example usages of Terratest

Prerequisites:
1. AWS profile(s) and respective configuration(s) in ~/.aws.
How you've configured your AWS connectivity doesn't matter how as long as you can apply and destroy AWS resources via terraform.
Setting up your Terratest environment
1. After cloning the repository, fetch the go and Terratest dependencies with the included script 
   2. % sh setup_go.sh
   3. execute 'terraform init' from /infrasture directory in order to initialze providers and modules. You'll need this before executing terratest. 
3. The terraform in main.tf fetches and utilizes some of the modules defined in my Github repo github.com/borisveis/terraform_modules/
4. **Execute Terratest**
5. from root of repo, 'go test'

6. **What Terratest does**
   7. Executes terraform in 'infrastructure/main.tf'
   8. Retrieves some outputs from invoked terraform
   9. Utilizes terraform outputs assigned to variables making assertions on their values.
   10. Finally: Terratest destroys all the resources it created regardless of the test(s) outcome.
