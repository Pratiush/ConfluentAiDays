#!/usr/bin/env python3
"""
Healthy Lifestyle Recommendation System
Based on Doctor Prescriptions using Confluent Kafka and AWS Bedrock
"""

import json
import boto3
import time
import ssl
import urllib3
from datetime import datetime
from typing import Dict, List, Any
import logging

# Disable SSL warnings for corporate environments
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class HealthLifestyleApp:
    def __init__(self):
        """Initialize the Health Lifestyle Recommendation App"""
        # Configure boto3 client with SSL verification disabled for corporate environments
        self.lambda_client = boto3.client(
            'lambda', 
            region_name='us-west-2',
            verify=False  # Disable SSL verification for corporate environments
        )
        
    def process_prescription(self, prescription_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process a doctor's prescription and generate lifestyle recommendations"""
        
        try:
            # Add timestamp to prescription
            prescription_data['timestamp'] = int(time.time())
            
            logger.info(f"Processing prescription for patient: {prescription_data.get('patient_name')}")
            
            # For demonstration, we'll directly invoke the Lambda function
            # In a production setup, this would send to Kafka topic
            
            # Lambda function name from terraform deployment
            lambda_function_name = "health-lifestyle-processor-4lb2a1"
            
            response = self.lambda_client.invoke(
                FunctionName=lambda_function_name,
                InvocationType='RequestResponse',
                Payload=json.dumps(prescription_data)
            )
            
            result = json.loads(response['Payload'].read())
            return result
            
        except Exception as e:
            logger.error(f"Error processing prescription: {str(e)}")
            return {"error": str(e), "status": "error"}
    
    def create_sample_prescription(self, patient_name: str, condition: str) -> Dict[str, Any]:
        """Create a sample prescription for testing"""
        
        sample_prescriptions = {
            "diabetes": {
                "patient_id": "P001",
                "patient_name": patient_name,
                "age": 45,
                "gender": "M",
                "medical_condition": "Type 2 Diabetes",
                "prescribed_medicines": [
                    {
                        "name": "Metformin",
                        "dosage": "500mg",
                        "frequency": "twice daily",
                        "timing": ["morning", "evening"],
                        "duration": "3 months",
                        "instructions": "Take with meals"
                    },
                    {
                        "name": "Glibenclamide",
                        "dosage": "5mg",
                        "frequency": "once daily",
                        "timing": ["morning"],
                        "duration": "3 months",
                        "instructions": "Take before breakfast"
                    }
                ],
                "doctor_notes": "Patient needs to monitor blood sugar levels daily. Follow up in 4 weeks.",
                "lifestyle_restrictions": [
                    "Avoid high sugar foods",
                    "Limit refined carbohydrates",
                    "Regular exercise recommended",
                    "Monitor weight"
                ]
            },
            "hypertension": {
                "patient_id": "P002",
                "patient_name": patient_name,
                "age": 52,
                "gender": "F",
                "medical_condition": "High Blood Pressure",
                "prescribed_medicines": [
                    {
                        "name": "Amlodipine",
                        "dosage": "5mg",
                        "frequency": "once daily",
                        "timing": ["morning"],
                        "duration": "6 months",
                        "instructions": "Take at the same time each day"
                    },
                    {
                        "name": "Hydrochlorothiazide",
                        "dosage": "25mg",
                        "frequency": "once daily",
                        "timing": ["morning"],
                        "duration": "6 months",
                        "instructions": "Take with food"
                    }
                ],
                "doctor_notes": "Monitor blood pressure twice daily. Reduce sodium intake significantly.",
                "lifestyle_restrictions": [
                    "Low sodium diet",
                    "Limit alcohol consumption",
                    "Regular moderate exercise",
                    "Stress management important"
                ]
            },
            "anxiety": {
                "patient_id": "P003",
                "patient_name": patient_name,
                "age": 28,
                "gender": "F",
                "medical_condition": "Generalized Anxiety Disorder",
                "prescribed_medicines": [
                    {
                        "name": "Sertraline",
                        "dosage": "50mg",
                        "frequency": "once daily",
                        "timing": ["morning"],
                        "duration": "6 months",
                        "instructions": "Take with breakfast, may cause drowsiness initially"
                    }
                ],
                "doctor_notes": "Patient to start therapy sessions. Monitor mood changes closely.",
                "lifestyle_restrictions": [
                    "Limit caffeine intake",
                    "Avoid alcohol",
                    "Regular sleep schedule essential",
                    "Practice stress reduction techniques"
                ]
            }
        }
        
        return sample_prescriptions.get(condition, sample_prescriptions["diabetes"])

def main():
    """Main function to demonstrate the Health Lifestyle Recommendation System"""
    
    print("🩺 HEALTHY LIFESTYLE RECOMMENDATION SYSTEM")
    print("=" * 60)
    print("Based on Doctor Prescriptions using AI")
    print("Powered by Confluent Kafka + AWS Bedrock")
    print()
    
    app = HealthLifestyleApp()
    
    # Interactive mode
    while True:
        print("\n📋 Choose an option:")
        print("1. Process sample diabetes prescription")
        print("2. Process sample hypertension prescription") 
        print("3. Process sample anxiety prescription")
        print("4. Create custom prescription")
        print("5. Exit")
        
        choice = input("\nEnter your choice (1-5): ").strip()
        
        if choice == "1":
            patient_name = input("Enter patient name: ").strip() or "John Doe"
            prescription = app.create_sample_prescription(patient_name, "diabetes")
            
        elif choice == "2":
            patient_name = input("Enter patient name: ").strip() or "Jane Smith"
            prescription = app.create_sample_prescription(patient_name, "hypertension")
            
        elif choice == "3":
            patient_name = input("Enter patient name: ").strip() or "Emily Johnson"
            prescription = app.create_sample_prescription(patient_name, "anxiety")
            
        elif choice == "4":
            print("\n📝 Create Custom Prescription:")
            patient_name = input("Patient name: ").strip()
            age = input("Age: ").strip()
            gender = input("Gender (M/F): ").strip()
            condition = input("Medical condition: ").strip()
            medicines = input("Prescribed medicines (comma-separated): ").strip().split(",")
            notes = input("Doctor's notes: ").strip()
            
            prescription = {
                "patient_id": f"P{int(time.time()) % 1000}",
                "patient_name": patient_name,
                "age": int(age) if age.isdigit() else 35,
                "gender": gender,
                "medical_condition": condition,
                "prescribed_medicines": [med.strip() for med in medicines],
                "doctor_notes": notes,
                "lifestyle_restrictions": []
            }
            
        elif choice == "5":
            print("\n👋 Thank you for using the Health Lifestyle Recommendation System!")
            break
            
        else:
            print("❌ Invalid choice. Please try again.")
            continue
        
        # Process the prescription
        print(f"\n🔄 Processing prescription for {prescription['patient_name']}...")
        print(f"📊 Medical Condition: {prescription['medical_condition']}")
        
        # Display prescription details
        print(f"\n📋 PRESCRIPTION DETAILS:")
        print(f"Patient: {prescription['patient_name']} (Age: {prescription['age']}, Gender: {prescription['gender']})")
        print(f"Condition: {prescription['medical_condition']}")
        print(f"Prescribed Medicines:")
        for med in prescription['prescribed_medicines']:
            if isinstance(med, dict):
                print(f"  • {med['name']} - {med['dosage']} {med['frequency']}")
            else:
                print(f"  • {med}")
        print(f"Doctor's Notes: {prescription.get('doctor_notes', 'None')}")
        
        # Process with AI
        result = app.process_prescription(prescription)
        
        if result.get('status') == 'success':
            print(f"\n✅ SUCCESS: Generated lifestyle recommendations!")
            print(f"\n🤖 AI-POWERED RECOMMENDATIONS:")
            
            recommendations = result.get('recommendations', {})
            if 'recommendations' in recommendations:
                # Pretty print the recommendations
                for category, items in recommendations['recommendations'].items():
                    print(f"\n📌 {category.upper()}:")
                    if isinstance(items, list):
                        for item in items[:3]:  # Show first 3 items
                            print(f"  • {item}")
                    elif isinstance(items, dict):
                        for key, value in list(items.items())[:2]:  # Show first 2 items
                            print(f"  • {key}: {value}")
                    else:
                        print(f"  • {items}")
            
            # Show medicine reminders
            medicine_reminders = result.get('medicine_reminders', [])
            if medicine_reminders:
                print(f"\n💊 MEDICINE REMINDERS:")
                for reminder in medicine_reminders:
                    print(f"  • {reminder['medicine_name']}: {reminder['dosage']} {reminder['frequency']}")
                    if reminder.get('timing'):
                        print(f"    ⏰ Best times: {', '.join(reminder['timing'])}")
        else:
            print(f"\n❌ ERROR: {result.get('error', 'Unknown error occurred')}")
        
        print(f"\n" + "="*60)

if __name__ == "__main__":
    main() 