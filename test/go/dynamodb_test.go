package test

import (
    "testing"
    "os"
    "path/filepath"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestDynamodbModule(t *testing.T) {
    versionsDir := "../modules/dynamodb"
    versionDirs, err := os.ReadDir(versionsDir)
    if err != nil {
        t.Fatal(err)
    }

    for _, version := range versionDirs {
        if version.IsDir() {
            t.Run(version.Name(), func(t *testing.T) {
                terraformOptions := &terraform.Options{
                    TerraformDir: filepath.Join(versionsDir, version.Name()),
                    Vars: map[string]interface{}{},
                    EnvVars: map[string]string{
                        "AWS_ACCESS_KEY_ID":     "test",
                        "AWS_SECRET_ACCESS_KEY": "test",
                        "AWS_REGION":            "us-east-1",
                    },
                }
# main.tf
module "dynamodb_context" {
  source = "../../dynamodb"
  # ... existing config
}

module "lambda_handler" {
  source = "../../lambda"
  # ... existing config
}

module "api_gateway" {
  source = "../../api_gateway"
  # ... existing config
}
                defer terraform.Destroy(t, terraformOptions)
                terraform.InitAndApply(t, terraformOptions)

                output := terraform.Output(t, terraformOptions, "example_output")
                assert.NotEmpty(t, output)
            })
        }
    }
}}
