data "template_file" "puppet-server" {
  template = "${file("install_server.sh")}"

  vars {
    dns_name = "${aws_elb.my-elb.dns_name}"
  }
}

resource "aws_launch_configuration" "example-launchconfig" {
  name_prefix     = "PuppetServer-launchconfig"
  image_id        = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.mykeypair.key_name}"
  security_groups = ["${aws_security_group.myinstance.id}"]

  root_block_device {
    volume_size           = "12"
    delete_on_termination = true
  }

  #user_data            = "#!/bin/bash\nyum update\nyum -y install epel-release\nyum -y install nginx\nsystemctl start nginx.service\nMYIP=`ifconfig | grep 'inet 10' | awk '{print $2}'`\necho 'this is: '$MYIP > /usr/share/nginx/html/index.html"
  #user_data = "${file("install_server.sh")}"
  user_data = "${data.template_file.puppet-server.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example-autoscaling" {
  name = "PuppetServer-autoscaling"

  #vpc_zone_identifier  = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  vpc_zone_identifier       = ["${aws_subnet.main-private-1.id}", "${aws_subnet.main-private-2.id}"]
  launch_configuration      = "${aws_launch_configuration.example-launchconfig.name}"
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = ["${aws_elb.my-elb.name}"]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "PuppetServer ec2 instance"
    propagate_at_launch = true
  }
}
