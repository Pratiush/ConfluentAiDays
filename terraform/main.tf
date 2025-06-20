terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

variable "cc_cloud_api_key" {}
variable "cc_cloud_api_secret" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_session_token" {}
variable "aws_region" {
  default = "us-west-2"
}

provider "confluent" {
  cloud_api_key    = var.cc_cloud_api_key
  cloud_api_secret = var.cc_cloud_api_secret
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Confluent Environment for Healthy Lifestyle App
resource "confluent_environment" "health_env" {
  display_name = "healthy-lifestyle-system-${random_string.suffix.result}"
}

# Kafka Cluster
resource "confluent_kafka_cluster" "health_cluster" {
  display_name = "health-recommendations-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_region
  
  basic {}
  
  environment {
    id = confluent_environment.health_env.id
  }
}

# Service Account
resource "confluent_service_account" "health_sa" {
  display_name = "health-lifestyle-sa"
  description  = "Service account for healthy lifestyle recommendation system"
}

# API Keys
resource "confluent_api_key" "health_api_key" {
  display_name = "health-kafka-api-key"
  description  = "Kafka API Key for health system"
  
  owner {
    id          = confluent_service_account.health_sa.id
    api_version = confluent_service_account.health_sa.api_version
    kind        = confluent_service_account.health_sa.kind
  }
  
  managed_resource {
    id          = confluent_kafka_cluster.health_cluster.id
    api_version = confluent_kafka_cluster.health_cluster.api_version
    kind        = confluent_kafka_cluster.health_cluster.kind
    
    environment {
      id = confluent_environment.health_env.id
    }
  }
}

# Note: Topics and ACLs will be created manually through Confluent Cloud UI
# This avoids REST endpoint and authorization complexities 