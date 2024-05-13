resource "aws_codestarconnections_connection" "github" {
  name          = "gtihub-connection"
  provider_type = "GitHub"
}
