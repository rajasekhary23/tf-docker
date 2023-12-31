resource "aws_key_pair" "terraform" {
  key_name = "terraform"
  public_key = file("/Users/rajaseky/.ssh/terraform.pub")
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_all_ports"
  description = "Allow all ports"
  vpc_id      = "vpc-01e2bd86538e32aa2" #default vpc id

  ingress {
    description      = "allow_all_ports"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_ports"
  }
}

resource "aws_instance" "your-wish" {
    ami = "ami-012b9156f755804f5"
    # from instance_type map instance will be selected based on the current workspace
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform.key_name
    security_groups = [aws_security_group.allow_tls.name]
    user_data = "${file("scripts/docker.sh")}"
    # where you are running terraform command
    provisioner "local-exec" {
        command = "echo The server's IP address is ${self.public_ip} > public_ip.txt"
    }
}

# resource "aws_instance" "remote" {
#     ami = "ami-012b9156f755804f5"
#     # from instance_type map instance will be selected based on the current workspace
#     instance_type = "t3.micro"
#     key_name = aws_key_pair.provisioner.key_name
#     security_groups = [aws_security_group.allow_tls.name]

#     connection {
#         type     = "ssh"
#         user     = "ec2-user"
#         private_key = file("C:\\Users\\user\\provisioner.pem")
#         host     = self.public_ip
#     }

#     # provisioner "remote-exec" {
#     #     inline = [
#     #         "touch /tmp/remote.txt",
#     #         "echo 'this file is created by remote provisioner' > /tmp/remote.txt"
#     #     ]
#     # }

#     provisioner "remote-exec" {
#         script = "scripts/docker.sh"
#     }

#     # provisioner "remote-exec" {
#     #     inline = [
#     #         "id",
#     #         "sudo amazon-linux-extras install nginx1 -y",
#     #         "sudo systemctl start nginx"
#     #     ]
#     # }
# }