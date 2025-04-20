package test

import (
    "testing"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestS3Module(t *testing.T) {{
    t.Parallel()

    terraformOptions := &terraform.Options{{
        TerraformDir: "../modules/s3",
        Vars: map[string]interface{}{{}},
        EnvVars: map[string]string{{
            "AWS_ACCESS_KEY_ID":     "test",
            "AWS_SECRET_ACCESS_KEY": "test",
            "AWS_REGION":            "us-east-1",
        }},
    }}

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    output := terraform.Output(t, terraformOptions, "example_output")
    assert.NotEmpty(t, output)
}}
