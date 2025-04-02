# Terratest
 example usages of Terratest

Setting up your Terratest environment
1. After cloning the repository, execute the go and Terratest dependencies with the included script
   a % sh setup_go.sh
2. Verify your system's Terraform environment by applying the included Terraform. Note: The Terraform uses remote modules on my github. If you prefer, clone that repository and change the source attributes for each of the module dependencies
   % cd infrastructure
3. % terraform init
3. % terraform plan -out=planfile.out
4. terraform apply planfile.out
5. *Don't forget to destroy % terraform destroy
5. When this succeeds, you are ready to execute the Terratest
cd to root of repo
6. cd ..
7. % go test