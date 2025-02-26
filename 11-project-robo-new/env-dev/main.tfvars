env="dev"
bastion_nodes=["172.31.3.63/32"]
zone_id="Z02556032JV56RSCGA16T"
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

apps={
    frontend={
        subnet_ref= "web"
        instance_type = "t3.small"
        allow_port = 80
        allow_sg_cidr = ["10.10.0.0/24","10.10.1.0/24"]# allow public subnet traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
        allow_lb_sg_cidr=["0.0.0.0/0"]
        capcity={
            desired=1
            max=1
            min=1
        }
        lb_internal=false # passing wheteher load balncer to be internal or not
        lb_subnet_ref="public"
        acm_https_arn="arn:aws:acm:ap-south-2:058264470882:certificate/23739d0a-47c2-473f-95bc-c1c0639c0763"

    }
    catalogue={
        subnet_ref= "app"
        instance_type = "t3.small"
        allow_port = 8080
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow web subnet for app- traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
        allow_lb_sg_cidr=["10.10.2.0/24","10.10.3.0/24","10.10.4.0/24","10.10.5.0/24"]
        capcity={
            desired=1
            max=1
            min=1
        }
        lb_internal=true
        lb_subnet_ref="app"
        acm_https_arn= null
    }
    user={
        subnet_ref= "app"
        instance_type = "t3.small"
        allow_port = 80
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow web subnet for app- traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
        allow_lb_sg_cidr=["10.10.2.0/24","10.10.3.0/24","10.10.4.0/24","10.10.5.0/24"] # sometimes need internal connection itsel through load balancer
        capcity={
            desired=1
            max=1
            min=1
        }
        lb_internal=true
        lb_subnet_ref="app"
        acm_https_arn= null
    }
    cart={
        subnet_ref= "app"
        instance_type = "t3.small"
        allow_port = 80
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow web subnet for app- traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
        allow_lb_sg_cidr=["10.10.2.0/24","10.10.3.0/24","10.10.4.0/24","10.10.5.0/24"]
        capcity={
            desired=1
            max=1
            min=1
        }
        lb_internal=true
        lb_subnet_ref="app"
        acm_https_arn= null
    }
    shipping={
        subnet_ref= "app"
        instance_type = "t3.small"
        allow_port = 80
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow web subnet for app- traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
        allow_lb_sg_cidr=["10.10.2.0/24","10.10.3.0/24","10.10.4.0/24","10.10.5.0/24"]
        capcity={
            desired=1
            max=1
            min=1
        }
        lb_internal=true
        lb_subnet_ref="app"
        acm_https_arn= null
    }
    payment={
        subnet_ref= "app"
        instance_type = "t3.small"
        allow_port = 80
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow web subnet for app- traffic only
        # it can acces internet-hidden using nat gateway, but ir will allow only incoming traffic from public
        allow_lb_sg_cidr=["10.10.2.0/24","10.10.3.0/24","10.10.4.0/24","10.10.5.0/24"]
        capcity={
            desired=1
            max=1
            min=1
        }
        lb_internal=true
        lb_subnet_ref="app"
        acm_https_arn= null
    }
}
db={
    mongo={
        subnet_ref= "db"
        instance_type = "t3.small"
        allow_port = 27017
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow only ap subnets to access security
    }
    mysql={
        subnet_ref= "db"
        instance_type = "t3.small"
        allow_port = 3306
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow only ap subnets to access security
    }
    rabbitmq={
        subnet_ref= "db"
        instance_type = "t3.small"
        allow_port = 5672
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow only ap subnets to access security
    }
    redis={
        subnet_ref= "db"
        instance_type = "t3.small"
        allow_port = 6379
        allow_sg_cidr = ["10.10.4.0/24","10.10.5.0/24"]# allow only ap subnets to access security
    }
}

# change in vault port 8080 -> 80
#secrets-cart, and shipping as 80,payment->80