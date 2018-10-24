provider "aws" {
  region = "${var.location}"
}

# Get subnet data
data "aws_subnet" "subnet" {
  cidr_block = "${var.subnet}"
}

# Get admin secrurity group
data "aws_security_group" "sgs" {
  count = "${length(var.security_group_names)}"
  tags = {
    Name = "${element(var.security_group_names, count.index)}"
  }
}

# Get centos7 image id
data "aws_ami" "centos7" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}



# Create repository instance
module "instance_ec2" {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance"

  name                        = "${var.instance_name}-${count.index}"
  count                       = "${var.instance_count}"
  ami                         = "${data.aws_ami.centos7.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  monitoring                  = true
  vpc_security_group_ids      = ["${data.aws_security_group.sgs.*.id}"]
  subnet_id                   = "${data.aws_subnet.subnet.id}"
  user_data                   = "${var.user_data_path != "" ? file(var.user_data_path) : ""}"
  private_ip                  = "${cidrhost(var.subnet, count.index + var.start_ip)}"
  root_block_device           = [{
                                  delete_on_termination = true,
                                  volume_size = "${var.os_size}"
                                }]

  tags                        = "${var.tags}"
}
resource "aws_volume_attachment" "repository_ec2" {
  count         = "${var.data_disk_size != 0 ? var.instance_count : 0}"
  device_name   = "/dev/sdb"
  volume_id     = "${element(aws_ebs_volume.repository_ec2.*.id, count.index)}"
  instance_id   = "${element(module.instance_ec2.id, count.index)}"
  force_detach  = true
}
resource "aws_ebs_volume" "repository_ec2" {
  count             = "${var.data_disk_size != 0 ? var.instance_count : 0}"
  availability_zone = "${module.instance_ec2.availability_zone[0]}"
  size              = "${var.data_disk_size}"
}