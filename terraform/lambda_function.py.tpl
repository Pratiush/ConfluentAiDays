import json
import boto3
import os
import logging
from typing import Dict, List, Any

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class HealthRecommendationProcessor:
    def __init__(self):
        self.bedrock_client = boto3.client('bedrock-runtime', region_name='${aws_region}')
        self.model_id = "anthropic.claude-3-5-haiku-20241022-v1:0"
        
    def generate_lifestyle_recommendations(self, prescription_data: Dict[str, Any]) -> Dict[str, Any]:
        """Generate personalized lifestyle recommendations based on doctor prescription"""
        
        patient_name = prescription_data.get('patient_name', 'Patient')
        age = prescription_data.get('age', 'Unknown')
        gender = prescription_data.get('gender', 'Unknown')
        medical_condition = prescription_data.get('medical_condition', '')
        prescribed_medicines = prescription_data.get('prescribed_medicines', [])
        doctor_notes = prescription_data.get('doctor_notes', '')
        lifestyle_restrictions = prescription_data.get('lifestyle_restrictions', [])
        
        prompt = f"""
You are a certified health and wellness expert. Based on the following doctor's prescription, generate comprehensive lifestyle recommendations:

PATIENT DETAILS:
- Name: {patient_name}
- Age: {age}
- Gender: {gender}
- Medical Condition: {medical_condition}
- Doctor's Notes: {doctor_notes}

PRESCRIBED MEDICINES:
{chr(10).join([f"- {med}" for med in prescribed_medicines])}

LIFESTYLE RESTRICTIONS:
{chr(10).join([f"- {restriction}" for restriction in lifestyle_restrictions])}

Please provide detailed, personalized recommendations in the following categories:

1. DIETARY RECOMMENDATIONS:
   - Foods to include for faster recovery
   - Foods to avoid due to medical condition or medicine interactions
   - Meal timing suggestions
   - Hydration guidelines

2. EXERCISE & PHYSICAL ACTIVITY:
   - Safe exercises considering the medical condition
   - Activity modifications needed
   - Duration and intensity recommendations
   - Warning signs to stop activity

3. SLEEP & REST PATTERNS:
   - Optimal sleep duration
   - Sleep hygiene tips
   - Rest periods during day
   - Sleep position recommendations if relevant

4. STRESS MANAGEMENT:
   - Relaxation techniques
   - Meditation or breathing exercises
   - Activities to avoid stress
   - Mental health support suggestions

5. MEDICINE ADHERENCE TIPS:
   - Best times to take medications
   - Food interactions to consider
   - Reminders and tracking suggestions
   - Side effects to monitor

6. LIFESTYLE MODIFICATIONS:
   - Daily routine adjustments
   - Environmental changes needed
   - Social activity modifications
   - Work-life balance tips

7. WARNING SIGNS & WHEN TO CONTACT DOCTOR:
   - Symptoms that require immediate medical attention
   - Regular monitoring parameters
   - Follow-up schedule suggestions

Please make recommendations specific, actionable, and tailored to this patient's condition. Use encouraging but professional tone.

Return the response as a well-structured JSON object with clear categories and actionable items.
"""

        try:
            body = {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 4000,
                "temperature": 0.3,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            }
            
            response = self.bedrock_client.invoke_model(
                modelId=self.model_id,
                body=json.dumps(body),
                contentType='application/json',
                accept='application/json'
            )
            
            response_body = json.loads(response['body'].read())
            ai_response = response_body['content'][0]['text']
            
            # Try to extract JSON from response
            try:
                if '```json' in ai_response:
                    json_start = ai_response.find('```json') + 7
                    json_end = ai_response.find('```', json_start)
                    json_str = ai_response[json_start:json_end].strip()
                    recommendations = json.loads(json_str)
                else:
                    # If no JSON markers, try to parse the whole response
                    recommendations = json.loads(ai_response)
            except json.JSONDecodeError:
                # Fallback to text response if JSON parsing fails
                recommendations = {
                    "ai_response": ai_response,
                    "format": "text"
                }
            
            return {
                "patient_id": prescription_data.get('patient_id'),
                "patient_name": patient_name,
                "medical_condition": medical_condition,
                "recommendations": recommendations,
                "generated_timestamp": prescription_data.get('timestamp'),
                "status": "success"
            }
            
        except Exception as e:
            logger.error(f"Error generating recommendations: {str(e)}")
            return {
                "patient_id": prescription_data.get('patient_id'),
                "patient_name": patient_name,
                "medical_condition": medical_condition,
                "error": str(e),
                "status": "error"
            }
    
    def generate_medicine_reminders(self, prescription_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Generate medicine reminder schedule"""
        
        prescribed_medicines = prescription_data.get('prescribed_medicines', [])
        patient_id = prescription_data.get('patient_id')
        patient_name = prescription_data.get('patient_name', 'Patient')
        
        reminders = []
        
        for medicine in prescribed_medicines:
            if isinstance(medicine, dict):
                medicine_name = medicine.get('name', 'Unknown Medicine')
                dosage = medicine.get('dosage', '1 tablet')
                frequency = medicine.get('frequency', 'twice daily')
                timing = medicine.get('timing', ['morning', 'evening'])
                duration = medicine.get('duration', '7 days')
                special_instructions = medicine.get('instructions', '')
            else:
                # Handle string format
                medicine_name = str(medicine)
                dosage = "As prescribed"
                frequency = "As directed"
                timing = ["morning", "evening"]
                duration = "As prescribed"
                special_instructions = "Follow doctor's instructions"
            
            reminder = {
                "patient_id": patient_id,
                "patient_name": patient_name,
                "medicine_name": medicine_name,
                "dosage": dosage,
                "frequency": frequency,
                "timing": timing,
                "duration": duration,
                "special_instructions": special_instructions,
                "reminder_type": "medicine_intake",
                "created_timestamp": prescription_data.get('timestamp')
            }
            reminders.append(reminder)
        
        return reminders

def lambda_handler(event, context):
    """Main Lambda handler"""
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        processor = HealthRecommendationProcessor()
        
        # Handle different event sources
        if 'Records' in event:
            # Handle Kafka/SQS records
            for record in event['Records']:
                if 'value' in record:
                    # Kafka record
                    prescription_data = json.loads(record['value'])
                else:
                    # SQS record
                    prescription_data = json.loads(record['body'])
                    
                process_prescription(processor, prescription_data)
        else:
            # Direct invocation
            prescription_data = event
            return process_prescription(processor, prescription_data)
            
        return {
            'statusCode': 200,
            'body': json.dumps('Successfully processed prescriptions')
        }
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

def process_prescription(processor, prescription_data):
    """Process a single prescription"""
    try:
        # Generate lifestyle recommendations
        recommendations = processor.generate_lifestyle_recommendations(prescription_data)
        
        # Generate medicine reminders
        medicine_reminders = processor.generate_medicine_reminders(prescription_data)
        
        # For now, log the results (in real implementation, would send to Kafka)
        logger.info(f"Generated recommendations for patient: {prescription_data.get('patient_name')}")
        logger.info(f"Recommendations: {json.dumps(recommendations, indent=2)}")
        logger.info(f"Medicine reminders: {json.dumps(medicine_reminders, indent=2)}")
        
        return {
            "recommendations": recommendations,
            "medicine_reminders": medicine_reminders,
            "status": "success"
        }
        
    except Exception as e:
        logger.error(f"Error processing prescription: {str(e)}")
        return {
            "error": str(e),
            "status": "error"
        } 