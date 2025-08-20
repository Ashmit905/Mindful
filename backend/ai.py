from groq import Groq
import json
import os
from dotenv import load_dotenv
load_dotenv()
api_key = os.environ.get("API_KEY")

# Hardcoded model name
model_name = "llama-3.1-8b-instant"  

def getQuote():
    """Function to get a motivational quote"""

    client = Groq(api_key=api_key)

    try:
        completion = client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": "You are an AI that specializes in quote generation."},
                {"role": "user", "content": "Give me a unique and fresh motivational quote that is different every time."}
            ],
            temperature=0.9,  
            max_tokens=100,  
            top_p=1
        )

        return completion.choices[0].message.content

    except Exception as e:
        print(f"\nError: {e}\n")
        return "An error occurred while fetching the quote."
 
def get_insights(user_data: dict) -> dict:
    """Generate clinical-grade mental health analysis"""
    client = Groq(api_key=api_key)
    
    try:
        # Prepare timeline analysis
        timeline = ""
        if len(user_data.get('checkin_dates', [])) > 1:
            first_date = user_data['checkin_dates'][-1]
            last_date = user_data['checkin_dates'][0]
            timeline = f"\n- Check-in Timeline: From {first_date} to {last_date}"

        prompt = f"""
        As a senior clinical psychologist, analyze this patient's mental health data:

        CORE METRICS:
        - Mood Average: {user_data.get('average_mood', 0)}/10
        - Primary Emotion: {user_data.get('common_emotion', 'N/A')}
        - Check-in Consistency: {user_data.get('checkin_count', 0)} entries
        - Current Streak: {user_data.get('streak_days', 0)} days
        {timeline}

        EMOTIONAL PROFILE:
        {json.dumps(user_data.get('emotion_counts', {}), indent=2)}

        Required Output Format (STRICT JSON):
        {{
            "clinical_insights": [
                {{
                    "observation": "pattern description",
                    "interpretation": "professional analysis",
                    "significance": "clinical importance"
                }}
            ],
            "personalized_recommendations": [
                {{
                    "action": "specific suggestion",
                    "rationale": "evidence-based reason",
                    "priority": "high/medium/low"
                }}
            ],
            "therapeutic_note": "compassionate clinical summary"
        }}

        Analysis Guidelines:
        1. Identify mood-emotion correlations
        2. Note temporal patterns if data available
        3. Flag any concerning trends
        4. Suggest evidence-based interventions
        5. Maintain hopeful, non-alarmist tone
        6. Format strictly as JSON

        Example Insight:
        {{
            "observation": "Elevated anxiety on weekdays",
            "interpretation": "Work-related stress appears impactful",
            "significance": "Consistent with adjustment disorder patterns"
        }}
        """
        
        completion = client.chat.completions.create(
            model=model_name,
            messages=[
                {
                    "role": "system", 
                    "content": """You are Dr. Chen, a Harvard-trained psychologist with 15 years 
                    clinical experience. Provide nuanced analysis in precise JSON format."""
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.65,
            max_tokens=600,
            response_format={"type": "json_object"}
        )
        
        response = json.loads(completion.choices[0].message.content)
        
        insights = [
            f"{item['observation']}\n→ {item['interpretation']}" 
            for item in response.get('clinical_insights', [])
        ]
        
        suggestions = [
            f"{item['action']} ({item['priority']} priority)\n- {item['rationale']}"
            for item in response.get('personalized_recommendations', [])
        ]
        
        return {
            "success": True,
            "insights": insights[:3],  # Limit to top 3
            "suggestions": suggestions[:3],
            "note": response.get('therapeutic_note', 'Your self-awareness is commendable')
        }
        
    except Exception as e:
        print(f"Clinical Analysis Error: {e}")
        return {
            "success": False,
            "insights": [],
            "suggestions": [],
            "note": "Analysis temporarily unavailable"
        }