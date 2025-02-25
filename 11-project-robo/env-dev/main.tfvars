env="dev"
bastion_nodes=["172.31.3.63/32"]
vpc={
    cidr="10.10.0.0/16"
    public_subnets=["10.10.0.0/24","10.10.1.0/24"] # 24 will bring 56 ips az1 ,az2
    web_subnets=["10.10.2.0/24","10.10.3.0/24"] # 24 will bring 56 ips
    app_subnets=["10.10.4.0/24","10.10.5.0/24"] # 24 will bring 56 ips
    db_subnets=["10.10.6.0/24","10.10.7.0/24"] # 24 will bring 56 ips
    availability_zones=["ap-south-2a","ap-south-2b"]
    default_vpc_id="vpc-0a814be354897a863"
    default_vpc_rt="rtb-0cf04062d48dae201"
    default_vpc_cidr="172.31.0.0/16"
}

ec2={
    frontend={
        subnet_ref= "web"
        instance_type = "t3.small"
        allo_port = 80
        allow_sg_cidr = ["10.10.0.0/24","10.10.1.0/24"]# allow public subnet traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
    }
}