resource "aws_instance" "nat-instance" {
    ami = "ami-184dc970"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.mykeypair.key_name}"
    depends_on = ["aws_security_group.for-nat-instance"]
    subnet_id = "${aws_subnet.main-public-1.id}"
    vpc_security_group_ids = ["${aws_security_group.for-nat-instance.id}"]
    source_dest_check = false
    associate_public_ip_address = true
    root_block_device {
      volume_size = "8"
      delete_on_termination = true
    }
    tags {
      Name = "myNATinstance"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat-instance.id}"
    vpc = true
}
