output "chatbot_sns_arns" {
  description = "SNS topic integrated to AWS Chatbot"
  value       = var.enable_slack_integration ? awscc_chatbot_slack_channel_configuration.this[0].sns_topic_arns : null
}
