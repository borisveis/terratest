package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformS3BucketCreation(t *testing.T) {
	// Define Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "./infrastructure", // Adjust the path to where your Terraform files are located
	}

	// Clean up after the test
	defer terraform.Destroy(t, terraformOptions)

	// Initialize and apply the Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Retrieve the resource ARNs and ip
	codebuildArn := terraform.Output(t, terraformOptions, "codebuild_arn")
	bucketArn := terraform.Output(t, terraformOptions, "bucket_arn")
	ec2_ip := terraform.Output(t, terraformOptions, "ec2_ip")
	assert.NotEmpty(t, ec2_ip)

// 	Assert that the bucket ARN is not empty (indicating the S3 bucket was created)
	assert.NotEmpty(t, bucketArn)
	// Assert that the codebuild_arn is not empty (indicating the S3 bucket was created)
	assert.NotEmpty(t, codebuildArn)
	// Assert that the instance's ip is not empty (indicating the Spublic ip availabilty)
}
