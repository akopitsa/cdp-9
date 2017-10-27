data "template_file" "puppet-agent" {
  template = "${file("install_agent.sh")}"

  vars {
    dns_name = "${aws_elb.my-elb.dns_name}"
  }
}

resource "aws_instance" "puppet-agent" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"

  #    availability_zone = "${var.AVAILABILITY_ZONE}"
  root_block_device {
    volume_size           = "8"
    delete_on_termination = true
  }

  vpc_security_group_ids = ["${aws_security_group.myinstance.id}"]
  key_name               = "${aws_key_pair.mykeypair.key_name}"
  subnet_id              = "${aws_subnet.main-private-1.id}"
  depends_on             = ["aws_security_group.myinstance"]

  #user_data = "${file("agent_install.sh")}"
  user_data = "${data.template_file.puppet-agent.rendered}"

  tags {
    Name = "PuppetAgent"
  }
}
