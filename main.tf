# Create EC2 instances
resource "aws_instance" "instance" {
  ami = var.ami_id
  monitoring = var.monitoring
  instance_type = var.instance_type
  key_name = var.key_name
  get_password_data = var.get_password_data
  vpc_security_group_ids = var.security_group_ids
  subnet_id = var.subnet_id
  private_ip = var.private_ip
  iam_instance_profile = var.iam_instance_profile
  tags = {
    Name = var.name
    Description = var.description
  }
  lifecycle {
    ignore_changes = [
      key_name
    ]
  }
  # If authorized keys were set, populate user data script to set them on every boot
  user_data = var.authorized_keys == null ? null : templatefile("${path.module}/userdata.sh", {
    authorized_keys = var.authorized_keys,
    home = var.authorized_keys_home,
    custom_user_data = var.user_data
  })
  disable_api_termination = var.termination_protection
}

# Create elastic IPs where required
resource "aws_eip" "server_eip" {
  count = var.elastic_ip == true ? 1 : 0
  vpc = true
  tags = {
    Name = var.name
  }
}

# Associate elastic IPs with their instances
resource "aws_eip_association" "server_eip_association" {
  count = var.elastic_ip == true ? 1 : 0
  public_ip = aws_eip.server_eip[0].public_ip
  instance_id = aws_instance.instance.id
}
