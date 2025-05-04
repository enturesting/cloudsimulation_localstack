package test

import (
    "os"
    "path/filepath"
    "testing"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestEc2Module(t *testing.T) {
    t.Parallel()

    versionsDir := "../modules/ec2"
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

                defer terraform.Destroy(t, terraformOptions)
                terraform.InitAndApply(t, terraformOptions)

                output := terraform.Output(t, terraformOptions, "example_output")
                assert.NotEmpty(t, output)
            })
        }
    }
}}
