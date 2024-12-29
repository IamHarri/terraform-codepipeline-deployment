resource "aws_sns_topic" "codepipeline_approval" {
  name = "codepipeline-approval-topic"
}
resource "aws_sns_topic_subscription" "codepipeline_approval" {
  topic_arn = aws_sns_topic.codepipeline_approval.arn
  protocol  = "email"
  endpoint  = var.approval_email
}
