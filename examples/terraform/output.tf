output "chatbot_sns_arns" {
  description = "SNS topics created by AWS Chatbot"
  value       = module.pipelines.chatbot_sns_arns
}
