import os
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from firebase_admin import auth, firestore, messaging
from firebase_config import initialize_firebase
from twilio.rest import Client
from google.cloud.firestore_v1.base_query import FieldFilter

# Load environment variables
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(dotenv_path)

# Twilio Configuration
TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER')

# Initialize Firebase
db = initialize_firebase()

def send_sms_alert(client, to_phone, medicine_name, expiry_date):
    """Sends an SMS alert using Twilio"""
    message_body = f"MediTrack Safety Alert: Your medicine '{medicine_name}' will expire on {expiry_date}. Please prepare to safely dispose of it."
    try:
        message = client.messages.create(
            body=message_body,
            from_=TWILIO_PHONE_NUMBER,
            to=to_phone
        )
        print(f"✅ SMS sent to {to_phone}: SID {message.sid}")
    except Exception as e:
        print(f"❌ Failed to send SMS to {to_phone}: {e}")

def send_voice_call(client, to_phone, medicine_name, expiry_date):
    """Sends an automated Voice Call reading out the expiry warning using Twilio TwiML"""
    twiml_script = f"""
    <Response>
        <Say voice="Polly.Matthew" language="en-US">
            Hello! This is an important automated safety alert from Medi-Track.
            Your prescribed medicine, {medicine_name}, is approaching its expiration date on {expiry_date}.
            For your safety, please do not consume this medicine after it has expired.
            Thank you for using Medi-Track. Goodbye!
        </Say>
    </Response>
    """
    try:
        call = client.calls.create(
            twiml=twiml_script,
            from_=TWILIO_PHONE_NUMBER,
            to=to_phone
        )
        print(f"📞 Audio Call initiated to {to_phone}: SID {call.sid}")
    except Exception as e:
        print(f"❌ Failed to initiate call to {to_phone}: {e}")

def send_push_notification(fcm_token, medicine_name, expiry_date):
    """Sends a high-priority FCM Push Notification to the user's mobile app"""
    if not fcm_token:
        return
    
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title="🚨 Medicine Expiry Alert",
                body=f"Your medicine '{medicine_name}' will expire on {expiry_date}. Check your dashboard for details."
            ),
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    color="#FF5252",
                    sound="default",
                ),
            ),
            # Support for iOS/Web if needed in future
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default")
                )
            ),
            token=fcm_token
        )
        response = messaging.send(message)
        print(f"📲 Push Notification sent: {response}")
    except Exception as e:
        print(f"❌ Failed to send Push Notification: {e}")

def run_daily_expiry_check():
    """Scans the database for medicines expiring strictly in 7 days and triggers alerts."""
    print("Running Daily Expiry Alert Job...")
    
    if not TWILIO_ACCOUNT_SID or not TWILIO_AUTH_TOKEN:
        print("⚠️ Twilio credentials missing in .env. Skipping SMS/Voice execution.")
        return

    twilio_client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)

    # Calculate exactly 7 days from right now (using modern UTC aware datetime)
    now = datetime.now(timezone.utc)
    target_date = now + timedelta(days=7)
    target_date_str = target_date.strftime('%Y-%m-%d')
    print(f"Scanning for medicines expiring strictly on: {target_date_str}")

    # Fetch all active (non-disposed) medicines using the new FieldFilter syntax
    meds_ref = db.collection('medicines').where(filter=FieldFilter('disposed', 'in', [0, False])).stream()
    
    users_notified = 0

    for med in meds_ref:
        doc = med.to_dict()
        expiry_iso = doc.get('expiryDate', '')
        
        # Check if the expiry is exactly the target date
        if expiry_iso.startswith(target_date_str):
            user_id = doc.get('userId')
            medicine_name = doc.get('medicineName', 'Unknown Medicine')

            # Look up user's phone number
            user_doc = db.collection('users').document(user_id).get()
            if user_doc.exists:
                user_data = user_doc.to_dict()
                user_phone = user_data.get('phone')
                fcm_token = user_data.get('fcmToken')
                
                if fcm_token:
                    print(f"📲 Sending Push Notification for {medicine_name}...")
                    send_push_notification(fcm_token, medicine_name, target_date_str)
                
                if user_phone:
                    print(f"Found expiring match: {medicine_name} for user {user_phone}")
                    # 📩 TRIGGER 2: Send SMS Alert
                    send_sms_alert(twilio_client, user_phone, medicine_name, target_date_str)
                    # 📞 TRIGGER 3: Send Voice Call
                    send_voice_call(twilio_client, user_phone, medicine_name, target_date_str)
                
                users_notified += 1

    print(f"Job Complete. Total patients notified today: {users_notified}")

if __name__ == "__main__":
    run_daily_expiry_check()
