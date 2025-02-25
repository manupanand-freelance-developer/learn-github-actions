resource "aws_security_group" "allow_tls" {
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
# laod balancer security group
resource "aws_security_group" "load-balancer" {
  count = var.asg ? 1: 0 # only need to create when ASG is enabled
   name = "${var.name}-${var.env}-alb-sg"
   description = "${var.name}-${var.env}-alb-sg"
   vpc_id = var.vpc_id
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
   }
   ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = var.allow_sg_cidr
   }
   
   tags = {
     Name="${var.name}-${var.env}-alb-sg"
   }
}


# ec2 instance

# launch template

resource "aws_launch_template" "main" {
  count = var.asg ? 1: 0 # if asg is present set count to 1
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
  count = var.asg ? 1: 0 # if asg is present set count to 1
  name = "${var.name}-${var.env}-asg"
  desired_capacity = var.capacity["desired"]
  max_size = var.capacity["max"]
  min_size = var.capacity["min"]
  vpc_zone_identifier = var.subnet_ids
  target_group_arns = [aws_lb_target_group.main.*.arn[count.index]]
  
  launch_template {
    id=aws_launch_template.main.*.id[0]
    version = "$Latest"
  }
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.name}-${var.env}-asg"
  }
}

# when asg -> false->0 above will not run, but db need to be created
resource "aws_instance" "main" {
  count = var.asg ? 0: 1 # it should not run when asg is true, that mean other instances
  ami = data.aws_ami.ami-data.image_id
  instance_type = var.instance_type
  subnet_id = var.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  # launch commands
  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
    role_name= var.name
    env=var.env
    vault_token=var.vault_token
  }))
  tags = {
    Name= "${var.name}-${var.env}-db"
  }
}

# dns record
resource "aws_route53_record" "instance" {
   count = var.asg ? 0: 1
   zone_id = var.zone_id
   name= "${var.name}.${var.env}"
   type = "A"
   ttl= 10
   records = [aws_instance.main.*.private_ip[count.index]]
}

# load balancer

resource "aws_lb" "main" {
  # need to create only when auto scaling group is creating
   count = var.asg ? 1: 0
   name = "${var.name}-${var.env}-lb"
   internal =  true
   load_balancer_type = "application"
   security_groups = [aws_security_group.load-balancer.*.id[count.index]]
   subnets = var.subnet_ids
   tags = {
     Environment="${var.name}-${var.env}-lb"
   }

  
}

# target group for load balancer
resource "aws_lb_target_group" "main" {
  count = var.asg ? 1: 0
  #port for group is 8080
  name =  "${var.name}-${var.env}-lb-tg"
  port = var.allow_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
}# give target group arn to autoscaling group

# load balancer listener rule
resource "aws_lb_listener" "main" {
  count = var.asg ? 1: 0
  load_balancer_arn = aws_lb.main.*.arn[count.index]
  port = "80"
  protocol = "HTTP"
  default_action {
    type =  "forward"
    target_group_arn = aws_lb_target_group.main.*.arn[count.index]
  }
}