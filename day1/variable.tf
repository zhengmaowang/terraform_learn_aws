output "public_ip" {
 value = aws_instance.example.public_ip
 description = "The public ip of the web server"
}

