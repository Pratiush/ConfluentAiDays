#!/bin/bash

# Healthy Lifestyle Recommendation System - Deployment Script
set -e

echo "🩺 DEPLOYING HEALTHY LIFESTYLE RECOMMENDATION SYSTEM"
echo "=" * 60

# Check if environment is set
if [ -z "$TF_VAR_cc_cloud_api_key" ]; then
    echo "❌ Environment not set. Please run ./setup/init.sh first"
    exit 1
fi

echo "🔧 Step 1: Initialize Terraform"
cd terraform
terraform init

echo "🔍 Step 2: Plan Infrastructure"
terraform plan

echo "🚀 Step 3: Deploy Infrastructure"
terraform apply -auto-approve

echo "📋 Step 4: Getting deployment information"
echo ""
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo ""
echo "📊 Infrastructure Details:"
echo "Kafka Cluster: $(terraform output -raw kafka_bootstrap_servers)"
echo "Lambda Function: $(terraform output -raw lambda_function_name)"
echo ""
echo "📋 Kafka Topics Created:"
echo "- doctor-prescriptions (input)"
echo "- lifestyle-recommendations (output)"
echo "- medicine-reminders (output)"
echo ""
echo "🧪 Next Steps:"
echo "1. cd ../app"
echo "2. pip3 install -r requirements.txt"
echo "3. python3 health_lifestyle_app.py"
echo ""
echo "🎉 Ready to process doctor prescriptions!" 