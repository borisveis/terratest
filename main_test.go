package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformS3BucketCreation(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "./infrastructure", // Adjust the path to where your Terraform files are located
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	codebuildArn := terraform.Output(t, terraformOptions, "codebuild_arn")
	bucketArn := terraform.Output(t, terraformOptions, "bucket_arn")
	applicationIP := terraform.Output(t, terraformOptions, "application_ip")

	url := "http://" + applicationIP + ":8000"
	maxRetries := 10
	timeBetweenRetries := 5 * time.Second

	// Get status code and body for further use
	statusCode, body, err := GetWithRetry(url, maxRetries, timeBetweenRetries)
	assert.NoError(t, err)
	assert.Equal(t, 200, statusCode)

	// Parse and assert JSON response
	var response map[string]interface{}
	err = json.Unmarshal([]byte(body), &response)
	assert.NoError(t, err)
	// ✅ Assert that 'timestamp_ms' exists in response
	timestampRaw, exists := response["timestamp_ms"]
	assert.True(t, exists, "'timestamp_ms' key should exist in response")

	// ✅ Assert it's a float64 (JSON numbers are float64 in Go)
	timestampFloat, ok := timestampRaw.(float64)
	assert.True(t, ok, "'timestamp_ms' should be a number (float64)")
	// ✅ Assert it can be parsed as a duration in milliseconds
	_, err = time.ParseDuration(fmt.Sprintf("%.0fms", timestampFloat))
	assert.NoError(t, err, "'timestamp_ms' should be a valid millisecond duration")

	// Optional: Assert it's not from the year 1970 (i.e., it's "recent")
	ms := int64(timestampFloat)
	timestamp := time.UnixMilli(ms)
	assert.True(t, timestamp.After(time.Now().Add(-24*time.Hour)), "'timestamp_ms' should be within the last 24 hours")

	// Assert that the required outputs are not empty
	assert.NotEmpty(t, bucketArn)
	assert.NotEmpty(t, codebuildArn)
	assert.NotEmpty(t, applicationIP)
}

// Custom helper for retrying an HTTP request
func GetWithRetry(url string, maxRetries int, wait time.Duration) (int, string, error) {
	for i := 0; i < maxRetries; i++ {
		resp, err := http.Get(url)
		if err == nil && resp.StatusCode == 200 {
			defer resp.Body.Close()
			bodyBytes, _ := io.ReadAll(resp.Body)
			return resp.StatusCode, string(bodyBytes), nil
		}
		time.Sleep(wait)
	}
	return 0, "", fmt.Errorf("failed to get a successful response after %d retries", maxRetries)
}
