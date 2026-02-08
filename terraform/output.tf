output "instance_ip" {
  description = "To get Public IP"
  value = aws_instance.directus.public_ip
}

output "private_key" {
  description = "To get Genrated SSH-Key"
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}