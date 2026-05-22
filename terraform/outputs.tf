output "gateway_public_ip" {
  value = aws_eip.gateway.public_ip
}

output "inference_private_ip" {
  value = aws_instance.inference.private_ip
}
