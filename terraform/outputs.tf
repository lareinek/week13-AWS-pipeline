output "alb_dns" {
  value = aws_lb.app_alb.dns_name
}

output "vpc_id" {
  value = aws_vpc.my-vpc.id
}

output "application_url" {
  value = "http://${aws_lb.app_alb.dns_name}"
}
