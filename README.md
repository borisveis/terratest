# Terratest
 example usages of Terratest

Setting up your Terratest environment
1. After cloning the repository, fetch the go and Terratest dependencies with the included script
   a. % sh setup_go.sh
2. Verify your system's Terraform environment by applying the included Terraform. Note: The Terraform uses remote modules on my github.
   a. If you prefer, clone that repository and change the source attributes for each of the module dependencies
   b. https://github.com/borisveis/terraform_modules
   
   c.  % cd infrastructure
4. d. % terraform init
3. e. % terraform plan -out=planfile.out
4. f. terraform apply planfile.out
5. g. **Don't forget to destroy % terraform destroy**
6. When this succeeds, you are ready to execute the Terratest
   a. cd to root of repo
6. b. cd ..
7. c. % go test
