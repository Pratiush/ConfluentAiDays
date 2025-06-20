# 🩺 Healthy Lifestyle Recommendation System

**AI-Powered GenAI App for Personalized Healthcare**  
Generate lifestyle recommendations and medicine reminders based on doctor prescriptions using **Confluent Kafka** and **AWS Bedrock Claude Haiku**.

## 🏗️ Architecture

```
Doctor Prescription → Confluent Kafka → AWS Lambda → AWS Bedrock (Claude Haiku) → Lifestyle Recommendations + Medicine Reminders
```

## ✨ Features

- **🤖 AI-Powered Recommendations**: Uses AWS Bedrock Claude Haiku for intelligent analysis
- **📋 Prescription Processing**: Structured processing of doctor prescriptions  
- **🏃 Lifestyle Plans**: Personalized diet, exercise, sleep, and stress management advice
- **💊 Medicine Reminders**: Automated scheduling and adherence tips
- **⚡ Real-time Processing**: Confluent Kafka for scalable messaging
- **🔒 Secure**: AWS IAM roles and encrypted communications

## 🚀 Quick Deployment

### 1. **Setup Environment**
```bash
chmod +x setup/init.sh
./setup/init.sh
```

### 2. **Deploy Infrastructure**
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. **Test the System**
```bash
cd app
pip3 install -r requirements.txt
python3 health_lifestyle_app.py
```

## 📋 Infrastructure Components

### **Confluent Cloud**
- **Environment**: `healthy-lifestyle-system`
- **Kafka Cluster**: `health-recommendations-cluster`
- **Topics**:
  - `doctor-prescriptions` - Input prescriptions
  - `lifestyle-recommendations` - AI-generated recommendations
  - `medicine-reminders` - Medication schedules

### **AWS Services**
- **Lambda Function**: `health-lifestyle-processor`
- **Bedrock Model**: `anthropic.claude-3-5-haiku-20241022-v1:0`
- **IAM Roles**: Secure access to Bedrock and CloudWatch
- **CloudWatch Logs**: Monitoring and debugging

## 🧪 Testing with Sample Data

The app includes 3 built-in medical scenarios:

### **1. Type 2 Diabetes** 
```json
{
  "patient_name": "John Doe",
  "medical_condition": "Type 2 Diabetes",
  "prescribed_medicines": [
    {"name": "Metformin", "dosage": "500mg", "frequency": "twice daily"},
    {"name": "Glibenclamide", "dosage": "5mg", "frequency": "once daily"}
  ],
  "doctor_notes": "Monitor blood sugar daily. Follow up in 4 weeks."
}
```

### **2. High Blood Pressure**
```json
{
  "patient_name": "Jane Smith", 
  "medical_condition": "High Blood Pressure",
  "prescribed_medicines": [
    {"name": "Amlodipine", "dosage": "5mg", "frequency": "once daily"},
    {"name": "Hydrochlorothiazide", "dosage": "25mg", "frequency": "once daily"}
  ],
  "doctor_notes": "Monitor BP twice daily. Reduce sodium intake."
}
```

### **3. Generalized Anxiety Disorder**
```json
{
  "patient_name": "Emily Johnson",
  "medical_condition": "Generalized Anxiety Disorder", 
  "prescribed_medicines": [
    {"name": "Sertraline", "dosage": "50mg", "frequency": "once daily"}
  ],
  "doctor_notes": "Start therapy sessions. Monitor mood changes."
}
```

## 🤖 AI-Generated Recommendations

For each prescription, the AI generates:

### **🍎 Dietary Recommendations**
- Foods to include for faster recovery
- Foods to avoid due to medicine interactions
- Meal timing suggestions
- Hydration guidelines

### **🏃 Exercise & Physical Activity**
- Safe exercises for the medical condition
- Activity modifications needed
- Duration and intensity recommendations
- Warning signs to stop activity

### **😴 Sleep & Rest Patterns**
- Optimal sleep duration
- Sleep hygiene tips
- Rest periods during day
- Sleep position recommendations

### **🧘 Stress Management**
- Relaxation techniques
- Meditation and breathing exercises
- Stress-avoiding activities
- Mental health support suggestions

### **💊 Medicine Adherence Tips**
- Best times to take medications
- Food interactions to consider
- Reminders and tracking suggestions
- Side effects to monitor

### **🔄 Lifestyle Modifications**
- Daily routine adjustments
- Environmental changes needed
- Social activity modifications
- Work-life balance tips

### **⚠️ Warning Signs & Medical Alerts**
- Symptoms requiring immediate attention
- Regular monitoring parameters
- Follow-up schedule suggestions

## 📊 Sample AI Output

```json
{
  "patient_name": "John Doe",
  "medical_condition": "Type 2 Diabetes",
  "recommendations": {
    "dietary_recommendations": {
      "foods_to_include": ["leafy greens", "lean proteins", "whole grains"],
      "foods_to_avoid": ["refined sugars", "processed foods", "white bread"],
      "meal_timing": "Eat smaller, frequent meals every 3-4 hours",
      "hydration": "Drink 8-10 glasses of water daily"
    },
    "exercise_recommendations": {
      "safe_exercises": ["brisk walking", "swimming", "cycling"],
      "duration": "30 minutes daily, 5 days a week",
      "intensity": "moderate intensity, aim for slight breathlessness"
    }
  },
  "medicine_reminders": [
    {
      "medicine_name": "Metformin",
      "dosage": "500mg",
      "timing": ["morning", "evening"],
      "instructions": "Take with meals"
    }
  ]
}
```

## 🛠️ Customization

### **Adding New Medical Conditions**
Edit `app/health_lifestyle_app.py` and add new entries to `sample_prescriptions`:

```python
"your_condition": {
    "patient_id": "P004",
    "medical_condition": "Your Condition",
    "prescribed_medicines": [...],
    "doctor_notes": "...",
    "lifestyle_restrictions": [...]
}
```

### **Modifying AI Prompts**
Edit `terraform/lambda_function.py.tpl` to customize the Bedrock prompts for different recommendation categories.

### **Adding New Output Topics**
Modify `terraform/main.tf` to add additional Kafka topics for specific use cases.

## 📈 Monitoring & Debugging

### **CloudWatch Logs**
```bash
# View Lambda function logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/health-lifestyle-processor"
```

### **Kafka Topic Monitoring**
Use Confluent Cloud Console to monitor:
- Message throughput
- Consumer lag
- Topic partitions
- Schema registry usage

### **Lambda Function Metrics**
- Invocation count
- Error rate
- Duration
- Memory usage

## 💰 Cost Optimization

### **Expected Costs (per 1000 prescriptions)**
- **Confluent Kafka**: ~$0.10 (included in basic plan)
- **AWS Lambda**: ~$0.02 (compute time)
- **AWS Bedrock**: ~$1.50 (Claude Haiku tokens)
- **CloudWatch Logs**: ~$0.01 (log storage)

### **Cost Reduction Tips**
1. **Optimize prompts** to reduce token usage
2. **Use reserved Lambda capacity** for predictable workloads  
3. **Configure log retention** to 7 days for development
4. **Monitor Bedrock usage** and set up billing alerts

## 🔧 Production Deployment

### **Security Enhancements**
- Enable VPC for Lambda functions
- Use AWS Secrets Manager for API keys
- Implement API Gateway with authentication
- Add input validation and sanitization

### **Scalability Improvements**
- Increase Kafka topic partitions
- Add Lambda reserved concurrency
- Implement DLQ (Dead Letter Queue) for error handling
- Add retry logic with exponential backoff

### **Monitoring & Alerting**
- Set up CloudWatch alarms for error rates
- Configure SNS notifications for failures
- Implement health checks and dashboards
- Add structured logging with correlation IDs

## 🧪 Advanced Testing

### **Load Testing**
```bash
# Generate multiple prescriptions
for i in {1..10}; do
  python3 health_lifestyle_app.py --batch-mode --patient-name "Patient$i"
done
```

### **Integration Testing**
```bash
# Test direct Lambda invocation
aws lambda invoke \
  --function-name health-lifestyle-processor-SUFFIX \
  --payload '{"patient_name":"Test Patient","medical_condition":"Test"}' \
  response.json
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues and questions:
1. Check CloudWatch logs for detailed error information
2. Verify AWS credentials and Bedrock model access
3. Test with sample prescriptions in the interactive app
4. Monitor Kafka topics in Confluent Cloud console

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ using Confluent Kafka and AWS Bedrock**
