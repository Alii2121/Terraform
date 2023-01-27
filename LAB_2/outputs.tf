output "ec2-public-ip" {

    value = aws_instance.EC2[0].public_ip 
  
}

output "ec2-private-ip" {

    value = aws_instance.EC2[1].private_ip

  
}