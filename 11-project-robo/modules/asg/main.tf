resource "aws_security_group" "main" {
   name = "${var.name}-${var.env}-sg"
   description = "Allow tls inbound traffic and all outbound traffic"
   vpc_id = var.vpc_id
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
   }
   ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = var.bastion_nodes
   }
   ingress {
    from_port = var.allow_port
    to_port = var.allow_port
    protocol = "TCP"
    cidr_blocks = var.allow_sg_cidr
   }
   tags = {
     Name="${var.name}-${var.env}-sg"
   }
}
# launch template

resource "aws_launch_template" "main" {
#   count = var.asg ? 1: 0 # if asg is present set count to 1 |mandatory
  name= "${var.name}-${var.env}-lt"
  image_id = data.aws_ami.ami-data.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  # launch commands
  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
    role_name= var.name
    env=var.env
    vault_token=var.vault_token
  }))
  tags = {
     Name="${var.name}-${var.env}-lt"
   }
}

# auto scaling group
resource "aws_autoscaling_group" "main" {
#   count = var.asg ? 1: 0 # if asg is present set count to 1
  name = "${var.name}-${var.env}-asg"
  desired_capacity = var.capacity["desired"]
  max_size = var.capacity["max"]
  min_size = var.capacity["min"]
  vpc_zone_identifier = var.subnet_ids
  target_group_arns = [aws_lb_target_group.main.arn]
  
  launch_template {
    id=aws_launch_template.main.id
    version = "$Latest"
  }
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.name}-${var.env}-asg"
  }
}
