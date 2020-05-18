module "imank-ssh-public-key" {
  source = "./modules/key-pair"
  key_name = "imank-ssh-public-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "salt-master" {
  source = "./modules/security-group"
  name = "salt-master"
  description = "Allow ssh inbound traffic"
  vpc_id = "vpc-4cc2dd2b" # default vpc
  ingress_rules = [
  {
    description = "SSH from Intenet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["122.179.150.123/32", "223.229.159.63/32", "182.70.17.160/32", "122.169.63.143/32", "182.70.42.83/32", "223.229.208.230/32", "182.70.11.196/32", "192.168.0.0/24"]
  },
  {
    description = "RDP from Intenet"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["122.179.150.123/32", "223.229.159.63/32", "182.70.17.160/32","122.169.63.143/32", "182.70.42.83/32", "223.229.208.230/32", "182.70.11.196/32", "192.168.0.0/24"]
  },
  {
    description = "Tomcat from Intenet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "ALB from Intenet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "salt traffic"
    from_port   = 4505
    to_port     = 4505
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "salt traffic"
    from_port   = 4506
    to_port     = 4506
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]

  egress_rules = [
  {
    description = "Traffic to Intenet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]
}

module "salt-master-instance" {
  source = "./modules/ec2"
  name = "salt-master"
  ami = "ami-0ec225b5e01ccb706"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-cab073ac" # default vpc
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "salt-master-public_ip" {
  value = module.salt-master-instance.public_ip
}

module "web" {
  source = "./modules/ec2"
  name = "web"
  ami = "ami-0ec225b5e01ccb706"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-cab073ac" # default vpc
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "web-public_ip" {
  value = module.web.public_ip
}


module "app" {
  source = "./modules/ec2"
  name = "app"
  ami = "ami-0ec225b5e01ccb706"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  subnet_id = "subnet-cab073ac" # default vpc
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "app-public_ip" {
  value = module.app.public_ip
}