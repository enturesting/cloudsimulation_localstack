package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestKmsModule(t *testing.T) {

	versionsDir := "../../modules/kms"
	versionDirs, err := os.ReadDir(versionsDir)
	if err != nil {
		t.Fatal(err)
	}

	for _, version := range versionDirs {
		if version.IsDir() {
			t.Run(version.Name(), func(t *testing.T) {
				terraformOptions := &terraform.Options{
					TerraformDir: filepath.Join(versionsDir, version.Name()),
					Vars:         map[string]interface{}{},
					EnvVars: map[string]string{
						"AWS_ACCESS_KEY_ID":     "test",
						"AWS_SECRET_ACCESS_KEY": "test",
						"AWS_REGION":            "us-east-1",
					},
				}

				// Initialize and validate terraform configuration
				terraform.Init(t, terraformOptions)

				// Validate the terraform configuration
				terraform.Validate(t, terraformOptions)

				// Since this is a module test, we mainly want to validate syntax
				// Full integration tests should be done with actual infrastructure
				t.Logf("KMS module %s validation completed successfully", version.Name())
			})
		}
	}
}
