module "ec2" {
  source = "../../../"

  name          = "example-ec2"
  ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t3.micro"
}
