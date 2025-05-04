# Example EC2 module usage
# module "ec2_instance" {
#   source        = "../ec2"
#   ami_id        = var.ami_id
#   instance_type = "t3.micro"
#   user_data     = file("scripts/bootstrap.sh")
#   providers = {
#     aws = aws.localstack
#   }
# }
