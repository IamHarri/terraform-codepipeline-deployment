resource "aws_ssm_parameter" "codepipeline" {
  for_each = local.codepipeline_variables
  name     = "/codepipeline/${each.key}"
  type     = "String"
  value    = each.value
}
