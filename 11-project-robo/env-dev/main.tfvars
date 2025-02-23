env="dev"
vpc={
    cidr="10.10.0.0/16"
    public_subnets=["10.10.0.0/24","10.10.1.0/24"] # 24 will bring 56 ips az1 ,az2
    web_subnets=["10.10.2.0/24","10.10.3.0/24"] # 24 will bring 56 ips
    app_subnets=["10.10.4.0/24","10.10.5.0/24"] # 24 will bring 56 ips
    db_subnets=["10.10.6.0/24","10.10.7.0/24"] # 24 will bring 56 ips
    availability_zones=["ap-south-2a","ap-south-2b"]
    default_vpc_id="vpcid"
    default_vpc_rt="routetable"
    default_vpc_cidr="172.0.0/16"
}
