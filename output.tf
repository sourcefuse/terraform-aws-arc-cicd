output "chatbot_sns_arns" {
  description = "SNS topic integrated to AWS Chatbot"
  value       = var.chatbot_data != null ? module.chatbot[0].chatbot_sns_arns : null
}
