################################################################################
# EC2 Key Pair for SSH Access to instances
################################################################################

resource "tls_private_key" "demo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo" {
  key_name   = "${local.name}-key"
  public_key = tls_private_key.demo.public_key_openssh
  tags       = local.tags

  provisioner "local-exec" {
    # Save private key to local machine
    command = "echo '${tls_private_key.demo.private_key_pem}' > ~/.ssh/${local.name}-key.pem; chmod 400 ~/.ssh/${local.name}-key.pem"
  }
}
