data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "dawsi_node_id" {
  byte_length = 2
  count       = var.main_instance_count
}

resource aws_key_pair "dawsi_node_id" {
  key_name = var.key_name
  public_key = file(var.public_key_path)
  
}

resource "aws_instance" "dawsi_main" {
  count         = var.main_instance_count
  instance_type = var.main_instance_type
  ami           = data.aws_ami.server_ami.id
  key_name = aws_key_pair.dawsi_node_id.key_name
  vpc_security_group_ids = [aws_security_group.dawsi_sg.id]
  subnet_id              = aws_subnet.dawsi_public_subnet[count.index].id
  #user_data = templatefile("./main-userdata.tpl", {new_hostname = "dawsi-main-${random_id.dawsi_node_id[count.index].dec}"})
  
  root_block_device {
    volume_size = var.main_vol_size
  }
  
    provisioner "local-exec" {
    command = "printf '\n${self.public_ip}' >> aws_hosts && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region eu-west-1"
  }
  
   tags = {
    Name = "dawsi-main-${random_id.dawsi_node_id[count.index].dec}"
  }
  
  
}

resource "null_resource" "grafana_install" {
  depends_on = [aws_instance.dawsi_main]
  provisioner "local-exec" {
    command = "ansible-playbook -i aws_hosts --key-file /home/ubuntu/.ssh/id_rsa playbooks/main-playbook.yml"
  }
}

output "instance_ips" {
  value = { for i in aws_instance.dawsi_main[*] : i.tags.Name => "${i.public_ip}:3000" }
}