output "kafka_cluster_id" {
  description = "Confluent Kafka Cluster ID"
  value       = confluent_kafka_cluster.health_cluster.id
}

output "kafka_bootstrap_servers" {
  description = "Kafka Bootstrap Servers"
  value       = confluent_kafka_cluster.health_cluster.bootstrap_endpoint
}

output "kafka_api_key" {
  description = "Kafka API Key"
  value       = confluent_api_key.health_api_key.id
}

output "kafka_api_secret" {
  description = "Kafka API Secret"
  value       = confluent_api_key.health_api_key.secret
  sensitive   = true
}

output "prescriptions_topic" {
  description = "Doctor Prescriptions Topic Name (create manually in UI)"
  value       = "doctor-prescriptions"
}

output "recommendations_topic" {
  description = "Lifestyle Recommendations Topic Name (create manually in UI)"
  value       = "lifestyle-recommendations"
}

output "reminders_topic" {
  description = "Medicine Reminders Topic Name (create manually in UI)"
  value       = "medicine-reminders"
}

output "lambda_function_name" {
  description = "Health Processor Lambda Function Name"
  value       = aws_lambda_function.health_processor.function_name
}

output "lambda_function_arn" {
  description = "Health Processor Lambda Function ARN"
  value       = aws_lambda_function.health_processor.arn
}

output "environment_id" {
  description = "Confluent Environment ID"
  value       = confluent_environment.health_env.id
}

output "service_account_id" {
  description = "Confluent Service Account ID"
  value       = confluent_service_account.health_sa.id
} 