# ssh_ip.tf
# Automatically fetch the public IP of the machine running terraform apply for SSH access

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  ssh_access_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}
